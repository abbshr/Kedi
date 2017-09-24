require "kedi/operator"

module Kedi
  class Selector < Edge
    id :selector

    def initialize(&p)
      @filter = p
    end

    process do |input_event|
      @filter.(input_event) && yield input_event
    end  

    # def select(event)
    #   @filter.(event) && yield event
    # end
  end
end