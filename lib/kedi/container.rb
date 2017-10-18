module Kedi
  class Container
    attr_reader :pipelines

    def initialize
      # 每个 pipe 按 unique name 装入
      @pipelines = {}
    end

    # 激活所有 pipes
    def run
      @pipelines.each &:streaming
    end

    def pause(id = nil)
      if id
        @pipelines[id]&.pause
      else
        @pipelines.each &:pause
      end
    end

    def resume(id = nil)
      if id
        @pipelines[id]&.resume
      else
        @pipelines.each &:resume
      end
    end

    def shutdown
      @pipelines.each &:stop
    end

    def restart
      @pipelines.each &:restart
    end

    def reload(id = nil)
      if id
        @pipelines[id]&.reload
      else
        @pipelines.each &:reload
      end
    end

    def remove(id)
      @pipelines.delete id
    end

    def add(pipeline)
      @pipelines[pipeline.name] = pipeline
    end

    def stats
      # TODO
      # 内部状态统计
    end
  end
end