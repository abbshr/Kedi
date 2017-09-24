module Kedi
  module Mathematic
    extend self

    @ops = MutState.new
    def calculator(sym_name, &p)
      @ops.get sym_name, &p
    end

    # class Rate < Calculator
    #   description "a rate operator for calculate rate"

    #   dependent :store
    #   option :actived_size, default: 10
    #   option :trait, required: true do |trait|
    #     trait.is_a? 
    #   end

    #   behavior do |event_set|
    #     break if event_set.size < @options.actived_size
    #     event_set.count { trait(event) } / event_set.size
    #   end
    # end
    class Calculator

      private def validate(config)
        
      end

      private def create(config)
        
      end
    end
  end
end