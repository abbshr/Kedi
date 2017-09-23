module Kedi
  class Dest < Edge
    id :dest

    process do |input_event|
      yield input_event
    end

  end
end