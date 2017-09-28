require "kedi/dag"
require "kedi/rest"
require "kedi/config"
require "kedi/version"
require "kedi/translate"
require "kedi/eventloop"

require "active_support/all"

module Kedi
  extend self
  attr_reader :config
  attr_accessor :container

  def standalone(&p)
    meow &p
    start_httpserver
    start_eventloop
  end

  def start_httpserver
    @httpserver = RestServer.new
  end

  def start_eventloop
    @eventloop = EventLoop.new
  end

  # def main
  #   case @config.mode
  #   when :standalone
  #   when :lib
  #   end
  # end

  def meow(&p)
    @config = Config.new
    Thread.abort_on_exception = true if @config.debug
    instance_eval &p if block_given?
    prepare
  end

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

  private
  def unsafe_load(path, ctx)
    eval File.read(path, encoding: "UTF-8"), ctx, path
  end
  
  def pipeline_loader(path)
    pipeline { unsafe_load path, binding }
  end
  
  def config_loader(path)
    unsafe_load path, binding
  end

  def pipeline(rule = nil, &p)
    pipe = Pipeline.new(rule, &p)
    pipe.streaming
  end

  private def prepare
    @container = generate_dag_container
  end

  private def get_raw_rules
    # flatten nested dirs & get rule file
    @config.rules_dir
  end

  private def generate_dag_container
    pipelines = load_rules
    DAG.new pipelines
  end

  def load_rules(from: :fs)
    case from
    when :fs then create_pipeline_from_fs
    when :persist then create_pipeline_from_persist
    end
  end

  def create_pipelines_from_fs
    get_raw_rules.map do |raw_rule|
      rule_skeleton = Translator.new raw_rule
      # rule = Rule.new rule_skeleton
      pipeline(rule_skeleton)
    end
  end

  def create_pipelines_from_persist
    Rule.all.map { |rule| pipeline(rule) }
  end
end
