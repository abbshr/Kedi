class Heap
  def initialize(head_elem = nil, &compare)
    @heap = []
    head_elem && @head << head_elem
    @compare = compare
  end

  def head
    @heap.first
  end

  def size
    @heap.size
  end

  def entry
    @heap
  end

  def insert(elem)
    @heap << elem
    siftup
  end

  def extract
    return nil if @heap.empty?
    head_elem = @heap.first
    siftdown
    head_elem
  end

  private
  def siftup
    i = @heap.size - 1

    loop do
      break if i <= 0
      p = (i / 2.0).ceil - 1
      break if @compare.(@heap[i], @heap[p]) >= 0
      swap(i, p)
      i = p
    end
  end

  private
  def siftdown
    last = @heap.pop
    @heap[0] = last if last && !@heap.empty?
    i = 0

    loop do
      break unless c = min_child(i)
      break if @compare.(@heap[i], @heap[c]) <= 0
      swap(i, c)
      i = c
    end
  end

  private
  def swap(i, j)
    tmp = @heap[i]
    @heap[i] = @heap[j]
    @heap[j] = tmp
  end

  private
  def min_child(i)
    c = 2*i + 1
    c += 1 if c + 1 <= @heap.size - 1 && @heap[c + 1] < @heap[c]
    c <= @heap.size - 1 && c
  end
end
