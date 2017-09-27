module Kedi
  class Inject < Edge
    id :inject

    process do |input_event|
      input_event.payload = @inject&.(input_event.payload)
      yield input_event
    end

    def initialize(path = nil, &map_block)
      @inject =
        if path.is_a? Array
          compile_map_block path
        else
          map_block
        end
    end

    def compile_map_block(path)
      lambda { |payload| payload.dig path }
    end
  end
end