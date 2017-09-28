disable :daemon
enable :debug
enable :sandbox, level: 3

# enable :daemon, pidfile: "/var/run/kedi.pid"

set :log, level: "debug",
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
