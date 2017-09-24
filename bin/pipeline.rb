from :stream {}
from :mysql {}

select { |event| event.everyday&.score }
overwrite_with :everyday, :score

use :window do
  type :time
  duration "10minute"
  every "5sec"
end

calc :means
fulfill do
  only lessthan(97.89)
end

to :http do |event|
  message "to low"
  url "http://example.com/alarm"
end

to :elasticsearch do |event|
  message "low watermarker alarm"
  hosts ""
end