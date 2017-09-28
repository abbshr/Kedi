require "kedi/operator"

module Kedi
  class Filter < Edge

    id :filter

    class CleanRoom
      include Operator
    end

    process do |input_event|
      @cleanroom.instance_exec(input_event, &@filter) && yield input_event
    end

    # TODO: 支持 YAML 查询语法
    def initialize(&condition_block)
      @filter = condition_block
      @cleanroom = CleanRoom.new
    end
  end
end