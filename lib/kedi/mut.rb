class MutState
  def initialize(hash = nil)
    @mut = {}
    if hash.is_a? Hash
      hash.each { |key, val| @mut[key.to_sym] = val }
    end
  end

  def method_missing(sym_name, value = nil)
    if sym_name.to_s.end_with?("=")
      @mut[sym_name[0..-2].to_sym] = value
    else
      @mut[sym_name]
    end
  end

  def clear
    @mut.clear
    nil
  end

  def has(k)
    @mut.include? k
  end

  def set(k, v)
    @mut[k] = v
  end

  def get(k)
    @mut[k]
  end

  def mut_ref
    @mut
  end

  def copy
    @mut.deep_dup
  end
end