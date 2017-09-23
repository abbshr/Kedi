require "kedi/event"

module Kedi
  class Source < Edge
    id :source

    consume do
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
  end
end