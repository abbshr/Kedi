module Kedi
  class Rule
    def initialize(rule_skeleton)
      
    end

    def sources
      
    end

    def dests
      
    end

    def filter
      
    end

    def injector
      
    end

    def storage
      
    end

    def calculator
      
    end

    def probe
      
    end
  end

  # class CalculatorHandle
  #   def initialize
      
  #   end
  # end

  # class Source
  #   def initialize
      
  #   end
  # end

  class ProbeHandle
    # PATH = %i(
    #   source
    #   filter
    #   injector
    #   store
    #   calculator
    #   probe
    #   destination
    # )

    # def initialize(pipeline, skeleton = nil)
    #   @path = []
    #   @pipeline = pipeline
    #   reshuffle(skeleton) if skeleton
    # end

    # def reshuffle(skeleton)
    #   PATH.each_with_index do |sym_edge_name, idx|
    #     edge = @pipeline.send sym_edge_name, skeleton[sym_edge_name]
    #     insert2(idx, edge)
    #   end
    # end

    # def add(sym_edge_name, edge)
    #   idx = PATH.find_index sym_edge_name
    #   insert2(idx, edge)
    # end

    # def insert2(idx, edge)
    #   @path[idx] ||= []
    #   @path[idx] << edge
    # end
  end
end