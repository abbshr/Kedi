require "redis-objects"

module Kedi
  module Persist
    def all
      
    end

    def get
      
    end

    def set
      
    end

    def del
      
    end
  end

  class RuleMapping
    include Persist

    def initialize(config)
      host = config.persist.host
      port = config.persist.port

      @prefix = config.persist.rule_prefix
      @client = Redis.new host: host, port: port
    end
  end
end