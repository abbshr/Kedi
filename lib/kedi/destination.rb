module Kedi
  class Dest < Edge
    id :dest

    process do |input_event|
      # custom underlying dest sendout code
    end

    def initialize(dest_name, &config_block)
      @dest_name = dest_name
      instance_eval &config_block if block_given?
    end

    def message(content = nil, &dynamic_gen_block)
      if content.nil?
        @message = dynamic_gen_block if block_given?
      else
        @message = content
      end
    end

    def level(lvl)
      @level = lvl
    end
  end
end