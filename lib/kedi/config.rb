require "optparse"
require "kedi/mut"

module Kedi
  class Config < MutState
    include Default

    # blank: 是否使用没有预配置的环境
    def initialize(blank = false)
      if blank
        # 不使用任何默认配置
        super()
      else
        argv_options = parse_argv
        # 合并生成配置项
        # 优先级：命令行 > 配置文件 > 默认值
        options = defaults
              .deep_merge!(load_config(argv_options[:config_file]))
              .deep_merge!(argv_options)
        super(options)
      end

      yield self if block_given?
    end

    private
    def defaults
      {

      }
    end

    # 从文件加载配置信息
    private
    def load_config
      cfgfile ||= CONFIG_FILE
      JSON.parse read_yaml(cfgfile).to_json, symbolize_names: true
    rescue Exception => e
      puts e.message
      { config_file: "" }
    end

    private
    def read_yaml(path)
      YAML.load File.read(File.expand_path(path))
    end

    # 解析命令行选项
    # TODO：配置选项待定
    private
    def parse_argv
      options = {}
      OptionParser.new do |opts|
        opts.banner = <<~BANNER
          A micro stream process engine for anomaly-detect (alarm system)
  
          Usage: bin/luna [options]

          options:
        BANNER

        opts.on "--debug" do
          options[:debug] = true
        end
  
        opts.on "-D", "--daemon", "Daemonilize Luna" do
          options[:daemon] = true
        end

        opts.on "-R DIR", "--rules-dir DIR", "Luna rulefiles dir" do |dir|
          options[:rules_dir] = dir
        end
  
        opts.on "--config FILE", "Use Luna config file" do |file|
          options[:config_file] = file
        end
  
        opts.on "--consume-retry-after N", "consuming data after N second if previous process failed" do |n|
          options[:consume_retry_after] = n
        end
  
        opts.on "--conn-retry-after N", "reconnect after N second if previous connection disconnected" do |n|
          options[:conn_retry_after] = n
        end
  
        opts.on "--max-retry-times N", "set max retry times" do |n|
          options[:max_retry_times] = n
        end
  
        opts.on "--open-timeout N", "socket establish timeout" do |n|
          options[:open_timeout] = n
        end
  
        opts.on "--log-level LEVEL", "log level" do |level|
          options[:log_level] = level
        end
        opts.on "--log-output TARGET_LIST", "logs send to TARGET_LIST" do |target_list|
          defaults = ["stdout", "stderr", "file"]
          options[:log_output] = target_list&.split(',') & defaults || defaults
        end
        opts.on "--log-path PATH", "log path" do |path|
          options[:log_path] = path
        end
        opts.on "--log-age AGE", "log retain interval" do |age|
          options[:log_age] = age
        end
        opts.on "--log-maxsize MAXSIZE", "log file max size" do |maxsize|
          options[:log_max_size] = maxsize
        end

        opts.on "--utc-offset OFFSET", "set UTC offset" do |offset|
          options[:utc_offset] = offset
        end
  
        opts.on "--pidfile PIDFILE", "pidfile used upon `--daemon` option" do |pidfile|
          options[:pidfile] = pidfile
        end
  
        opts.on "--web-server SERVER", "web server name to use" do |server|
          options[:web_server] = server
        end
        opts.on "--web-host HOST", "web server host to bind" do |host|
          options[:web_host] = host
        end
        opts.on "--web-port PORT", "web server port to bind" do |port|
          options[:web_port] = port
        end
  
        opts.on "--persist-host HOST", "redis host" do |host|
          options[:persist_host] = host
        end
        opts.on "--persist-port PORT", "redis port" do |port|
          options[:persist_port] = port
        end
        opts.on "--persist-key-prefix KEY_PREFIX", "redis key prefix to store Luna rules" do |key_prefix|
          options[:persist_key_prefix] = key_prefix
        end
  
        opts.on "--probes DIR", "set custom probes dir" do |dir|
          options[:probes_dir] = dir
        end
  
        opts.on "--sinks DIR", "set luna custom sinks dir" do |dir|
          options[:sinks_dir] = dir
        end
  
        opts.on "--sources DIR", "set luna custom sources dir" do |dir|
          options[:sources_dir] = dir
        end
      end.parse!
      options
    end

  end
end