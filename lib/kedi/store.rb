require "kedi/heap"

module Kedi
  module Store
    extend self

    def use(sym_name, &p)
      case sym_name
      when :ring then Ring
      when :list then InfiniteList
      when :hash then Hashie
      when :count_window then Window::CountWindow
      when :accurate_window then Window::AccurateWindow
      when :slide_window then Window::SlideWindow
      end.new &p
    end

    class State < Edge
      type :state
    end

    class Ring < State
      description "环状队列按照 event time 排序，顺序入队，触发传递输出整个存储区作为事件 payload"

      id :ring

      option :capacity, required: true # count number
      option :every, required: false # duration string

      process do |input_event|
        @store << input_event
        # 如果没有设置周期触发，则立即创建一个视图
        yield @store unless @periodic
      end

      def initialize
        super
        @store = RingBuffer.new(@options.capacity)

        if @options.every
          @periodic = Time.from(@options.every)
        end
      end

      def activate
        super
        trigger if @periodic
      end

      def trigger
        Thread.new do
          # 设置周期触发后，周期性 produce 整个 ring
          loop do
            sleep @periodic
            produce(@store)
          end
        end
      end

      class RingBuffer
        def initialize(capacity)
          @capacity = capacity
          @buf = []
          @tail = 0
        end

        def <<(event)
          @buf[@tail] = event
          @tail = (@tail + 1) % @capacity
        end
  
        def size
          @buf.size
        end
  
        def last
          @buf[@tail - 1]
        end
  
        def first
          if size < @capacity
            0
          else
            @tail
          end
        end
      end
    end

    module Window
      class CountWindow < State
        description "基于数量操作的窗口，窗口中元素数量达到 capacity 时触发，并将窗口前进 velocity 个元素"
        id :count_window
  
        option :capacity, required: true # count number
        option :velocity, required: true # removing count number
  
        process do |input_event|
          stash input_event
          yield @store if @store.size >= @capacity
          moving_forward @velocity
        end
  
        def initialize
          super
          @store = []
        end
  
        def stash(e)
          @store << e
        end
  
        def moving_forward(n)
          @store = @store[n..-1]
        end
      end

      class TimeWindow < State
        id :time_window

        option :sort_by, default: :event_time, available_values: [:event_time, :birth_time]
        option :enable_delay, default: 0
        option :duration, required: true

        process do |input_event|
          if @last_ack_time - input_event.timestamp > option.enable_delay
            # 标记为收到超过允许最长推迟时间的事件
            break mark_as_droped(input_event)
          end
          @store << input_event
          yield @store
        end

        def initialize
          @store =
          case @options.sort_by
          when :event_time then []
          when :birth_time then Heap.new { |event_a, event_b| event_a[:birth_time] - event_b[:birth_time] }
          end
        end

        def delta
          [@next_check_time - Time.now, 0].max
        end

        def cleaner
          Thread.new do
            loop do
              sleep delta
              now = Time.now
              update_next_check_time(now)
              produce(@store)
              clean(now)
            end
          end
        end

        def clean(now = Time.now)
          @store.extract while @store.head && now - @store.head.get(@sort_by) >= @duration - @velocity
        end

        def activate
          super
          @next_check_time = Time.now + @duration
          cleaner
        end
      end

      class SlideWindow < TimeWindow
        description "滑动窗口，清理时触发"
        id :slide_window

        option :velocity, default: :duration, required: false

        def update_next_check_time(now)
          @next_check_time = now + @velocity
        end
      end

      # class AccurateWindow < TimeWindow
      #   description "精确实时窗口，每收集一个事件做一次过期清理操作并触发，每一个清理也会产生一个触发"
      #   id :accurate_window

      #   process do |input_event|
      #     super
      #     # 清理当前视图中过期元素（如果存在）
      #     clean
      #     yield @store
      #   end

      #   def update_next_check_time
      #     @next_check_time =
      #     if @store.size == 0
      #       get_next_idle_check_time(@next_check_time)
      #     else
      #       @store.head.get(@sort_by) + @capacity
      #     end
      #   end

      #   def get_next_idle_check_time(curr_check_time)
      #     now = Time.now
      #     # 过去 @capacity (窗口大小) 时间里没有事件的情况下, 更新下一次检查时间
      #     # check time 可能是上一次已经更新过的
      #     if (curr_check_time..curr_check_time+@capacity).include? now
      #       curr_check_time + @capacity
      #     else
      #       now + @capacity
      #     end
      #   end

      #   def initialize
      #     @velocity = 0
      #   end
      # end
    end

    class InfiniteList < State
      id :list

      process do |input_event|
        @store << input_event
        yield @store
      end

      def initialize
        @store = []
      end
    end

    class Hashie < State
      id :hash

      option :key, required: true

      process do |input_event|
        @store.set(input_event[*@options.key], input_event)
      end

      def initialize
        @store = {}
      end
    end
  end
end