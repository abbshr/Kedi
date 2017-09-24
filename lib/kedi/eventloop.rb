module Kedi
  class EventLoop
    def initialize
      # 线程安全队列
      @recv_chan = Queue.new
      @alive? = false
    end

    def acquire()
      @recv_chan << {

      }
    end

    def schedule(message)
      
    end

    def run
      @alive? = true
      loop do
        break unless @alive?
        message = @recv_chan.deq
        schedule(message)
      end
    end

    def stop
      @alive? = false
    end

  end
end