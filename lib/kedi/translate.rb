require "yaml"

module Kedi
  # see grammer definitions
  # in doc/syntax.md
  class Translator
    attr_reader :sources
    attr_reader :filter
    attr_reader :inject
    attr_reader :store
    attr_reader :calculator
    attr_reader :probe
    attr_reader :destinitions

    attr_reader :string_rule
    attr_reader :hash_rule

    def initialize(string_rule)
      @string_rule = string_rule
      @hash_rule = hashilize(string_rule)
      parse @hash_rule
    end

    def hashilize(string_rule)
      YAML.load string_rule
    end

    def parse(hash_rule)
      parse_sources hash_rule["from"]
      parse_filter hash_rule["select"]
      parse_inject hash_rule["overwrite_with"]
      parse_store hash_rule["use"]
      parse_calculator hash_rule["cal"]
      parse_probe hash_rule["fulfill"]
      parse_destinations hash_rule["to"]
    end

    def parse_sources(hash_sources)
      raise "missing `from` declaration(s)" if hash_sources&.empty?
      @sources = hash_sources.map do |hash_source|
        parse_source hash_source
      end
    end

    def parse_source(hash_source)
      source_name = hash_source["name"]
      raise "missing `name` definition in `from` declaration(s)" if source_name.nil?
      hash_source["polling_interval"] = Time.from(hash_source["polling_interval"])
      hash_source
    end

    def parse_filter(hash_filter)
      @filter =
        if hash_filter.nil?
          nil
        elsif hash_filter.is_a? String
          parse_filter_code hash_filter
        else
          parse_filter_condition_literal hash_filter
        end
    end

    def parse_filter_code(string_code)
      exec("lambda { |event| \n#{string_code}\n }")
    end

    def parse_filter_condition_literal(filter_expression)
      raise "can not recognize a filter from the `select` expression: #{hash_filter}" unless probe_expression.is_a? Hash
      filter_expression
    end

    def parse_inject(hash_inject)
      @inject =
        if hash_inject.nil?
          nil
        elsif hash_inject.is_a? String
          parse_inject_code hash_inject
        else
          parse_inject_attr_path hash_inject
        end
    end

    def parse_inject_code(string_code)
      exec("lambda { |payload| \n#{string_code}\n }")
    end

    def parse_inject_attr_path(attr_path)
      unless attr_path.is_a? Array
        raise "`overwrite_with` declaration should be a list, but found a #{attr_path}"
      end
    end

    def parse_store(hash_store)
      @store =
        if hash_store.nil?
          nil
        else
          raise "missing `store` clause" if hash_store["store"].nil?
          # raise "unknown `sort_by` clause" if hash_store["sort_by"]
          # {
          #   store: hash_store["store"],
          #   sort_by: hash_store["sort_by"],
          #   enable_delay: Time.from(hash_store["enable_delay"]),

          # }
          hash_store["enable_delay"] = Time.from(hash_store["enable_delay"])
        end
    end

    def parse_calculator(hash_calculator)
      @calculator = hash_calculator
    end

    def parse_probe(hash_probe)
      raise "missing `fulfill` declaration" if hash_probe.nil?
      @probe =
        if hash_probe.is_a? String
          parse_probe_code hash_probe
        else
          parse_probe_condition_literal hash_probe
        end
    end

    def parse_probe_code(string_code)
      exec("lambda { |event| \n#{string_code}\n }")
    end

    def parse_probe_condition_literal(probe_expression)
      unless probe_expression.is_a? Hash
        raise "can not recognize a probe from the `fulfill` expression: #{probe_expression}"
      end
      probe_expression
    end

    def parse_destinations(hash_destinations)
      raise "missing `to` declaration(s)" if hash_destinations&.empty?
      @destinitions = hash_destinations.map do |hash_dest|
        parse_destination hash_dest
      end
    end

    def parse_destination(hash_dest)
      dest_name = hash_dest["name"]
      raise "missing `name` definition in `to` declaration(s)" if dest_name.nil?
      hash_dest
    end
  end
end