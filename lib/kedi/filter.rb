require "kedi/operator"

module Kedi
  class Filter < Edge
    id :filter

    process do |input_event|
      @cleanroom.instance_exec(input_event, &@filter) && yield input_event
    end

    class CleanRoom
      include Operator
    end

    def initialize(&condition_block)
      @filter = condition_block
      @cleanroom = CleanRoom.new
    end
  end
end