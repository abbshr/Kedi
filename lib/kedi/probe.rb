require "kedi/operator"
require "kedi/event"

module Kedi
  class Probe < Edge
    class << self
      def type(t = nil)
        t ? @type = t : @type
      end
    end

    def initialize(&p)
      @user_logic = p
    end

    def customize(&p)
      @user_logic = p
    end

    process do |input_event|
      yield @user_logic.(input_event)
    end

    produce do |output_event|
      # boolean stream
      output_event
    end

    def calculate(target)
      @user_logic.(target)
    end
  end
end