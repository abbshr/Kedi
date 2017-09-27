require "kedi/operator"
require "kedi/event"

module Kedi
  class Probe < Edge
    id :probe

    process do |input_event|
      fulfilled = 
        if @mode.nil?
          @cleanroom.instance_exec(input_event.payload, &@user_logic)
        elsif @mode == :custom
          @user_logic.(input_event)
        end

      if fulfilled.is_a? TrueClass
        yield template_alarm(input_event)
      elsif fulfilled.is_a? Hash
        yield fulfilled
      end
    end

    produce do |output_event|
      yield Event.alarm output_event
    end

    def template_alarm(event)
      {

      }
    end
    
    # def calculate(target)
    #   @user_logic.(target)
    # end

    # def self.type(t = nil)
    #   t ? @type = t : @type
    # end

    class CleanRoom
      include Operator
    end

    def initialize(mode, &condition_block)
      @mode = mode
      @user_logic = condition_block
      @cleanroom = CleanRoom.new
    end

    def customize(&p)
      @user_logic = p
    end
  end
end