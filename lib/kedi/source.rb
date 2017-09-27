require "kedi/event"

module Kedi
  class Source < Edge
    id :source

    consume do
      # custom underlying source retrieving code
    end

    process do |input_event|
      yield input_event
    end

    produce do |output_event|
      yield Event.create(output_event)
      # @next_chans.map do |chan|
      #   chan << Event.create(output_event)
      # end
    end

    def initialize(sym_source_name, &config_block)
      @name = sym_source_name
      instance_eval &config_block if block_given?
    end
  end
end