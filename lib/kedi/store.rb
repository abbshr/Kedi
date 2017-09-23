module Kedi
  module Store
    # class PriorityQueue
    #   def initialize
        
    #   end
    # end
    extend self

    def use(sym_name, &p)
      case sym_name
      when :window then Window
      when :ring then Ring
      when :list then InfiniteList
      when :hash then Hashie
      end.new &p
    end

    class State < Edge
      id :state

      option :sort_by, default: :event_time
      option :enable_delay, default: 0

      process do |input_event|
        @store << input_event
        yield @store.queue
      end

      def initialize
        @store = if config.sort_by == :event_time
          FifoQueue.new config
        else
          PrioriQueue.new config
        end
      end
    end

    class Window < State
      id :window

      def initialize
        
      end

      def active
        checker
        super
      end
    end

    class Ring < State
      id :ring

      option :capacity, required: true

      def initialize
        
      end
    end

    class CountWindow < Window
      id :count_window

      option :capacity, required: true

      full do |store|

      end

      def initialize
        
      end
    end

    class TimeWindow < Window
      id :time_window

      option :duration, required: true
      def initialize
        
      end

      def timer
        
      end
    end

    class AccurateWindow < TimeWindow
      id :accurate_window

      timeout do |store|
        yield input_event
      end

      def initialize
        
      end
    end

    class SlideWindow < TimeWindow
      id :slide_window

      option :vericity, default: :duration

      timeout do |input_event|

      end

      def initialize
        
      end
    end

    class InfiniteList < State
      id :list

      def initialize
        
      end
    end

    class Hashie < State
      id :hash

      def initialize
        
      end
    end
  end
end