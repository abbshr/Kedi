require "kedi/mut"
require "optparser"

module Kedi
  class Config < MutState
    # blank: 是否使用没有预配置的环境
    def initialize(blank = false)
      if blank
        super()
      else
        # 合并默认的配置项
        options = 
        super(options)
      end
    end

    def enable(sym_option_name, option_value = true)
      if option_value.is_a? FalseClass
        option_value = true
      end

      @mut[sym_option_name] = option_value
    end

    def disable(sym_option_name)
      @mut[sym_option_name] = false
    end

    def parse!
      option = {}
      Optparser.new do |opt|

      end.parse!
    end
  end
end