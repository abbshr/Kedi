# enable :log, path: "xxx"
# disable :metric

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

use :window do
  type :time
  duration "10minute"
  every "5sec"
end

calc :means
fulfill do |payload|
  only lessthan(97.89)
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