module Kedi
  class Injector < Edge
    id :injector

    def initialize(&p)
      @inject = p
    end

    process do |input_event|
      input_event.payload = @inject.(payload)
      yield input_event
    end

    # def inject(event)
    #   yield @inject.(event)
    # end
  end
end