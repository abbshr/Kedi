module Kedi
  module Operator
    def only(item)
      !!item
    end

    def both(*items)
      items.all?
    end

    def either(*items)
      items.any?
    end

    def not(item)
      !item
    end

    alias_method :is, :equal
    def equal(target, value)
      target == value
    end

    def isnt(target, value)
      target != value
    end

    alias_method :gt, :morethan
    def morethan(target, value)
      target > value
    end

    alias_method :lt, :lessthan
    def lessthan(target, value)
      target < value
    end

    def between(target, range)
      range.include? target
    end

    def similar(target, regexp)
      target =~ regexp
    end

    def start_with(target, prefix)
      target.start_with? prefix
    end

    def end_with(target, suffix)
      target.end_with? suffix
    end

    def has(target, value)
      target.include? value
    end

    alias_method :size, :length
    def length(target, value)
      target.size == value
    end
  end
end