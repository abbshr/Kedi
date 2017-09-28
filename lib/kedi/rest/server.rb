require "rack"

module Kedi
  module Rest
    class Server
      def initialize(config)
        require "kedi/rest/api/*"
      end
    end
  end
end