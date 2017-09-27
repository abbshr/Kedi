module Kedi
  class Pipeline
    PATH = %i(
      source
      filter
      inject
      store
      calculator
      probe
      destination
    )

    def initialize(skeleton = nil)
      @path = []
      reshuffle(skeleton) if skeleton
    end

    def streaming
      @path.reduce &:pipe
      @path.each do |group|
        group.each &:active
      end
      self
    end

    # get event stream
    def from(sym_source_name, &config_block)
      src = Source.new(sym_source_name, &config_block)
      add :source, src
    end

    # filter event
    def select(&condition_block)
      filter = Filter.new &condition_block
      add :filter, filter
    end

    # overwrite event with the certain value
    def overwrite_with(*path, &map_block)
      injector = Inject.new(path, &map_block)
      add :injector, injector
    end

    # use a state store
    def use(sym_store_name, &config_block)
      store = Store.use sym_store_name, &config_block
      add :store, store
    end

    # probe type, calculator
    def calc(sym_cal_name, &config_block)
      calculator = Mathematic.calculator sym_cal_name, &config_block
      add :calculator, calculator
    end

    # check if calculator fulfill
    def fulfill(mode = nil, &condition_block)
      probe = Probe.new mode, &condition_block
      add :probe, probe
    end

    # send out event stream
    def to(sym_dest_name, &config_block)
      dest = Dest.new sym_dest_name, &config_block
      add :destination, dest
    end

    private
    def reshuffle(skeleton)
      PATH.each_with_index do |sym_edge_name, idx|
        edge = self.send sym_edge_name, skeleton[sym_edge_name]
        insert2(idx, edge)
      end
    end

    private
    def add(sym_edge_name, edge)
      idx = PATH.find_index sym_edge_name
      insert2(idx, edge)
    end

    private
    def insert2(idx, edge)
      @path[idx] ||= []
      @path[idx] << edge
    end
  end
end