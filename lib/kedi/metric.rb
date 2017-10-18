require "java"
require "jruby"
require "kedi/ringbuffer"

module Kedi
  module Metric

    module System
      def memory_usage
        
      end

      def uptime
        
      end
    end

    module Storage
      def events_count
        @storage.count
      end

      def memory_usage
        
      end
    end

    # M/M/N
    module Container
      
    end

    # M/M/1
    module Pipeline
      def average_process_time
        
      end

      def average_process_rate
        
      end
    end

    # TODO
    # edge 根据排队论 M/M/1 模型建立监控指标
    # 请求随机，服务时间随机
    # 等待队列长度 = n，服务队列长度 = 1，服务队列并发 = 1
    module Edge
      # 输入队列上的等待数量
      def rx_chan_size
        @rx_chans.map &:size
      end

      def rx_chan_wait_num
        @rx_chans.map &:num_waiting
      end

      # # 输出队列上的等待数量（下一个等待队列）
      # def tx_chan_size
      #   @tx_chans.map &:size
      # end

      def tx_chan_wait_num
        @tx_chans.map &:num_waiting
      end

      def input_events
        @input_count
      end

      def droped_events
        @droped_count
      end

      def output_events
        @output_count
      end

      def average_process_time
        @process_span.sum / @process_span.size
      end

      def in_rate
        (@input_time.size - 1) / (@input_time.last - @input_time.first)
      end

      def out_rate
        (@output_time.size - 1) / (@output_time.last - @output_time.first)
      end

      def process_rate
        @process_span.map { |span| 1 / span }.sum / @process_span.size
      end

      def utilization_rate
        in_rate / process_rate
      end

      def average_wait_time
        average_respond_time - average_process_time
      end

      def average_respond_time
        1 / (process_rate - in_rate)
      end

      def state
        @state
      end

      def failure_times
        @failures
      end  

      def reload_times
        @reload_times
      end  

      def restart_times
        @restart_times
      end

      def fatal_times
        @fatals
      end

      private
      def setup(config)
        @input_count = 0
        @output_count = 0
        
        @input_time = RingBuffer.new config.metrics.buffer_size
        @output_time = RingBuffer.new config.metrics.buffer_size
        @process_span = RingBuffer.new config.metrics.buffer_size

        @failures = 0
        @fatals = 0
        @reload_times = 0
        @restart_times = 0
      end

      private
      def record_input_event
        now = Time.now.to_f
        @input_count += 1
        @input_time << now
        now
      end

      private
      def record_output_event
        now = Time.now.to_f
        @output_count += 1
        @output_time << now
        now
      end

      private
      def record_process_span(start_time, end_time)
        @process_span << (end_time - start_time)
      end

      private
      def record_failure
        @failures += 1
      end

      private
      def record_reload
        @reload_times += 1
      end

      private
      def record_restart
        @restart_times += 1
      end

      private
      def record_fatal
        @fatals += 1
      end
    end
  end
end