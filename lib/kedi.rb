require "kedi/dag"
require "kedi/rest"
require "kedi/config"
require "kedi/version"
require "kedi/translate"
require "kedi/eventloop"

module Kedi
  extend self
  attr_reader :config

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

  def meow(&p)
    @config = Config.new { |config| self.instance_exec(config, &p) } 
    prepare
  end

  def pipeline(rule = nil, &p)
    pipe = Pipeline.new(rule).instance_eval &p
    pipe.streaming
  end

  private def prepare
    generate_dag_container
  end

  private def generate_dag_container
    rule = Translate.new @config
    pipeline(rule)
  end
end
