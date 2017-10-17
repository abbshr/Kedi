# enable :log, path: "xxx"
# disable :metric

# A pipeline example process

name "origin"
description "example desc"

from :stream {}
from :mysql {}

select do |event|
  either(
    morethan(event.timestamp, 2333333333),
    isnt(event.host, "localhost")
  )

  # only lessthan(event.payload.size, 10.kb)
end
# select { |event| event.everyday&.score }

overwrite_with :everyday, :score

use :slide_window do
  duration "10minute"
  every "5sec"
end

# calc :means
calc :rate do
  option :actived_size, 25
  option :trait { |score| score % 2 != 0 }
end

fulfill do |payload|
  only lessthan(payload, 97.89)

  # # branch function
  # branch do |payload|
  #   to :next {}

  #   select {}
  #   use {}
  #   calc {}
  #   fulfill {}

  #   to {}
  # end
end
# fulfill :custom do |event|
#   { reason: "xxxx" } if event.payload ** 2 > 1024
# end

to :http do |event|
  message "to low"
  url "http://example.com/alarm"
end

to :elasticsearch do |event|
  message "low watermarker alarm"
  hosts ""
end