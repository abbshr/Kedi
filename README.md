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

## Kedi Pipeline DSL

```ruby
# A Kedi pipeline DSL

name "origin"
description "example desc"

from :stream {}
from :mysql {}

select do |event|
  either(
    morethan(event.timestamp, 2333333333),
    isnt(event.host, "localhost")
  )    
end
# select { |event| event.everyday&.score }

overwrite_with :everyday, :score

use :window do
  type :time
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
end


to :http do |event|
  message "to low"
  url "http://example.com/alarm"
end

to :elasticsearch do |event|
  message "low watermarker alarm"
  hosts ""
end
```

## Config DSL

```ruby
disable :daemon
enable :debug
enable :sandbox, level: 3

# enable :daemon, pidfile: "/var/run/kedi.pid"

enable :log, level: "debug",
             output: %w(stdout stderr file),
             path: "/var/log/kedi.log",
             age: "daily",
             size: "60mb"

set :rest, version: "v1",
           path_prefix: "/kedi",
           host: "127.0.0.1",
           port: 4096

set :persist, host: "127.0.0.1"
              port: 6379
              key_prefix: "MEOW"

set :connection, open_timeout: "10sec"
enable :retry, times: 15, after: "10sec"

set :utc_offset, "+08:00"
set :rules_dir, "../rules"
set :probes, dir: "../probes"
set :sources, dir: "../sources"
set :dests, dir: "../dests"
```