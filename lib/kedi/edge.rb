require "kedi/metrics"

module Kedi
  class Edge
    # class instance variables definition
    @description = ""
    @dependent_edges = []
    @options_requirements = {}

    # class macros definitions
    class << self
      # attr_accessor :description
      # attr_accessor :dependent_edges
      # attr_accessor :options_requirements

      # 声明或获取 edge id
      def id(sym_edge_id = nil)
        if sym_edge_id.nil?
          @id
        else
          @id = sym_edge_id
        end
      end

      def dependent(sym_dep_type)
        # 声明依赖的 edge type
        @dependencies_edge << sym_dep_type
      end

      def option(sym_option_name, required: false, available_values: [], default: nil, &custom_check_block)
        # 声明选项的配置需求
        @options_requirements[sym_option_name] = {
          default: default,
          required?: required,
          available_values: available_values,
          custom_check_block: custom_check_block,
        }
      end

      def description(str_desc)
        @description = str_desc
      end

      def consume(&consume_block)
        define_method :consume, &consume_block
      end

      alias_method :behavior, :process
      def process(&process_block)
        define_method :process, &process_block
      end

      def produce(&produce_block)
        define_method :produce, &produce_block
      end
    end

    def initialize(option, dependencies = [])
      @option = option
      @dependencies = dependencies

      @alive? = false
      # 需要使用线程安全的 channel
      @rx_chans = []
      @tx_chans = []

      validator
    end

    def id
      self.class.id
    end

    def dependencies
      self.class.instance_variable_get :@dependencies_edge
    end

    def requirements_set
      self.class.instance_variable_get :@options_requirements
    end

    def pipe(chan)
      @tx_chans << chan
    end

    def subscribe(chan)
      @rx_chans << chan
    end

    private def validator
      # 检查依赖 edge
      unless (lack = dependencies - @dependencies).empty?
        raise "#{id} lack of #{lack}"
      end

      # 检查配置项是否合法，并设置默认值
      requirements_set.each do |option_name, requirements|
        if option_value = @option.has(option_name)
          if requirements.available_values.empty?
             || requirements.available_values.include?(option_value)
          else
            raise "validation failed: option [#{option_name}] not in available values: [#{requirements.available_values}]"
          end
          if requirements.custom_check_block.nil?
            || requirements.custom_check_block.(option_value)
            raise "validation failed: option [#{option_name}] by block"
        elsif requirements.required?
          raise "validation failed: option [#{option_name}] is required for declaration [#{id}]"
        else
          @option.set(option_name, requirements.default)
        end
      end
    end

    private def consume
      # 默认会忽略 nil/faslse 数据
      @rx_chans.map do |chan|
        # 非阻塞 dequeue
        enq_time, event = chan.deq(true) raise nil
        deq_time = Time.now.to_f
        # 计算等待处理时间
        record_wait_span(enq_time, deq_time)
        yield event if event
      end
    end

    private def process(input_event)
      yield input_event
    end

    private def produce(output_event)
      @tx_chans.map do |chan|
        enq_time = Time.now.to_f
        chan << [enq_time, output_event]
      end
    end

    private def main_logic
      loop do
        break unless @alive?
        consume do |input_event|
          process(input_event) { |output_event| produce(output_event) }
        end
      end
    end

    public def activate
      @alive? = true
      @main_thr = Thread.new do
        main_logic
      end
    end

    public def deactivate
      @alive? = false
      # @main_thr.exit
    end

  end
end