module Kedi
  class DAG
    def initialize
      @pipelines = {}
    end

    def pipelines
      @pipelines
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
      @pipelines[pipeline.id] = pipeline
    end

    def stat
      
    end
  end
end