module Kedi
  class Edge
    class << self
      # declare / get edge id
      def id(sym_edge_id = nil)
        if sym_edge_id.nil?
          @id
        else
          @id = sym_edge_id
        end
      end

      def consume(&consume_block)
        
      end

      def process(&process_block)
        
      end

      def produce(&produce_block)
        
      end
    end

    def initialize
      @prev_chans = []
      @next_chans = []
    end

    def pipe(chan)
      @next_chans << chan
    end

    def subscribe(chan)
      @prev_chans << chan
    end

    def consume
      @prev_chans.map do |chan|
        # no blocking dequeue
        event = chan.deq(true) raise nil
        yield event if event
      end.compact
    end

    def process(input_event)
      yield input_event
    end

    def produce(output_event)
      @next_chans.map do |chan|
        chan << output_event
      end
    end

    def active
      @main_thr = Thread.new do
        loop do
          consume do |input_event|
            process(input_event) do |output_event|
              produce(output_event)
            end
          end
        end
      end
    end

  end
end