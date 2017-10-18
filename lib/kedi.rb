require "kedi/rest"
require "kedi/config"
require "kedi/version"
require "kedi/container"
# require "kedi/translate"
require "kedi/eventloop"

require "active_support/all"

module Kedi
  extend self
  attr_reader :config
  attr_accessor :container

  # 作为独立的 server 启动
  def standalone(&p)
    meow &p
    start_httpserver
    start_eventloop
  end

  # restful http server
  def start_httpserver
    @httpserver = RestServer.new
  end

  # 主线程接收消息、调度任务的事件循环
  def start_eventloop
    @eventloop = EventLoop.new
  end

  # 作为 gem 调用的入口 API
  def meow(&p)
    @config = Config.new
    Thread.abort_on_exception = true if @config.debug
    # 创建容纳 pipelines 的 container 
    @container = Container.new
    # 执行 DSL
    instance_eval &p if block_given?
    # 激活 pipelines
    @container.run
    # generate_dag_container.run
  end

  ## 创建 pipeline DSL
  def pipeline(rule = nil, name: nil, &p)
    pipe = Pipeline.new(rule, name, &p)
    @container.add(pipe)
    pipe
    # pipe.streaming
  end

  ## 配置文件 DSL
  # 启动/设置选项
  def enable(sym_option_name, option_value = true)
    if option_value.is_a? FalseClass
      option_value = true
    end

    @config.merge sym_option_name, option_value
  end

  # 禁用选项
  def disable(sym_option_name)
    @config.set sym_option_name, false
  end

  # 获取选项值
  def get(sym_option_name)
    @config.get sym_option_name
  end

  # 覆盖选项值
  def set(sym_option_name, value)
    @config.set sym_option_name, value
  end

  # 加载 DSL 文件
  private
  def unsafe_load(path, ctx)
    eval File.read(path, encoding: "UTF-8"), ctx, path
  end

  # 加载 pipeline 描述文件（rule 文件）
  def pipeline_loader(path)
    pipeline { unsafe_load path, binding }
  end

  # 加载配置文件
  def config_loader(path)
    unsafe_load path, binding
  end

  # 加载规则创建 pipeline
  def load_rules(from: :fs)
    case from
    when :fs then create_pipeline_from_fs
    when :persist then create_pipeline_from_persist
    end
  end

  # private def prepare
  #   @container = generate_dag_container
  # end

  private def get_raw_rules
    # flatten nested dirs & get rule file
    # TODO
    @config.rules_dir
  end

  private def generate_container
    pipelines = load_rules
    @container = Container.new pipelines
  end

  # 从 pipeline 描述文件中创建 pipes
  private def create_pipelines_from_fs
    get_raw_rules.map do |raw_rule|
      rule_skeleton = Translator.new raw_rule
      pipeline(rule_skeleton)
    end
  end

  # 从存储系统中创建 pipes
  private def create_pipelines_from_persist
    Rule.all.map { |rule| pipeline(rule) }
  end
end
