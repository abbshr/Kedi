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
require "kedi"

Kedi.meow do |config|
  config.enable :log, path: "/tmp/meow.log", size: 1024, by: :daily
  config.enable :debug
  config.enable :rules, path: ""
  config.enable :persist, host: "", port: "", prefix: ""

  config.enable :metrics

  pipeline do
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
  end

end
```