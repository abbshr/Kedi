module Kedi
  module Mathematic
    @calcs = MutState.new

    def self.calculator(sym_name, &config_block)
      @calcs.get(sym_name)&.new &config_block
    end

    # def self.calcs
    #   @calcs
    # end

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

    # Calculator = Class.new(Edge) do
    #   class << self
    #     alias_method :behavior, :process
    #   end

    #   def self.registry(sym_name)
    #     cals.set sym_name, self
    #   end
    # end

    class Calculator < Edge
      class << self
        alias_method :behavior, :process
      end

      def self.registry(sym_name)
        Mathematic
          .instance_variable_get :calcs
          .set sym_name, self
      end
    end

    class Sum < Calculator
      description "calc sum of a list"
      dependent :store

      behavior do |event_set|
        event_set.sum &:payload
      end
    end

    class Means < Calculator
      description "calc means of a list"
      dependent :store

      behavior do |event_set|
        event_set.sum &:payload / event_set.size
      end
    end

    class Max < Calculator
      description "get max value of the stream"
      dependent :store

      behavior do |event_set|
        event_set.max &:payload
      end
    end

    class Min < Calculator
      description "get min value of the stream"
      dependent :store

      behavior do |event_set|
        event_set.min &:payload
      end
    end

    class Count < Calculator
      description
      dependent :store

      behavior do |event_set|
        event_set.size
      end
    end

    class Rate < Calculator
      description
      dependent :store

      option :actived_size, default: 10
      option :trait, required: true

      behavior do |event_set|
        if event_set.size >= @options.actived_size
          yield event_set.count { |event| @options.trait.(event.payload) } / event_set.size
        end
      end
    end

  end
end