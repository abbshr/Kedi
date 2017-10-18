class RingBuffer
  def initialize(capacity)
    @capacity = capacity
    @buf = []
    @tail = 0
  end

  def <<(event)
    @buf[@tail] = event
    @tail = (@tail + 1) % @capacity
  end

  def size
    @buf.size
  end

  def last
    @buf[@tail - 1]
  end

  def first
    if size < @capacity
      @buf[0]
    else
      @buf[@tail]
    end
  end
end