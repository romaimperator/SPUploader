# The base class for all values stored for tags


class Generator
  def initialize(value)
    @value = value
  end
  
  def value
    return @value
  end
  
  def append_value(value)
    @value += value
  end
end
