# Kedi (In development)

a simple and elegant stream process framework

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kedi'
```

## State Transition Diagram

- `(…)` as a stream/state (DAG node)
- `<…>` as a process (DAG edge)

```
(raw data) -> <sources> -> (event) -> <filter> -> (event-1) -> <inject> -> (event-2) -> <store> -> ([event set]) -> <calculator> -> (event-3) -> <destinations> -> (event-4)
```

## Kedi DSL (May be like this …)

```ruby
# A Kedi pipeline DSL

# declaration multi-sources to create a event stream
from :redis
from :mysql do
  host "192.168.17.15"
  port 23333
  db ""
end

# select the certain event from the event stream to product a new event stream
select do |event|
  either(
    morethan(event.timestamp, 2333333333),
    isnt(event.host, "localhost")
  )
end
# select { |event| event.everyday&.score }

# overwrite the event payload with the certain field
overwrite_with :everyday, :score
# overwrite_with do |event|
#   event.everyday.score
# end

# collected events from the stream in a data structure store
use :window do
  type :time
  duration "10minute"
  every "5sec"
end

# calculate the result based on the event(set) stream
calc :means

# if the cal result fulfilled with the certain conditions
fulfill do |payload|
  only lessthan(97.89)
end
# fulfill :custom do |event|
#   { reason: "xxxx" } if event.payload ** 2 > 1024
# end

# when fulfilled, send new event to multi-dests
to :http do |event|
  message "to low"
  url "http://example.com/alarm"
end

to :elasticsearch do |event|
  message "low watermarker alarm"
  hosts ""
end
```