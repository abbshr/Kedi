module Kedi
  module Mathematic
    extend self

    @ops = MutState.new
    def operator(sym_name, &p)
      @ops.get sym_name, &p
    end
    # class Rate < Operator
    #   description "a rate operator for calculate rate"

    #   dependent :store
    #   option :actived_size, default: 10
    #   option :trait, required: true do |event|
    #     event.ip ~= %r(69\.43\.124\.\d)
    #   end

    #   behavior do |event_set|
    #     break if event_set.size < @options.actived_size
    #     event_set.count { trait(event) } / event_set.size
    #   end
    # end

    class Operator
      # class macros definitions
      class << self
        def description(des)
          
        end

        # other nodes
        def dependent(sym_name, args)
          
        end

        def option(sym_name, required: false, avaliable_values: [], default: nil, &p)
          
        end

        def behavior(&p)
          define_method
        end
      end

      def initialize(config)
        validate(config)
        create(config)
      end

      private def validate(config)
        
      end

      private def create(config)
        
      end
    end
  end
end