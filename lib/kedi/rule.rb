module Kedi
  class Rule
    # class << self
    #   include Persist
    # end
    include Persist

    def initialize
      host = Kedi.config.persist.host
      port = Kedi.config.persist.port

      @prefix = Kedi.config.persist.rule_prefix
      @client = Redis.new host: host, port: port
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