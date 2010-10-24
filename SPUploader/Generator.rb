# The base class for all values stored for tags
#
# To use just subclass and overload the method 'value'. For an example, refer
#  to the SSVGenerator class that is included.

class Generator
  def initialize(value)
    @value = value
  end
  
  
  # Returns the value stored in @value. Can be overloaded to provide any
  #  arbitrary value for the tag in the page provided the function returns a
  #  string.
  def value
    return @value
  end
  
  
  # Just in case, appends the passed value to the stored value.
  def append_value(value)
    @value += value
  end
end
