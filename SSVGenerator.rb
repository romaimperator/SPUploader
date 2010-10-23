require 'Generator'

class SSVGenerator < Generator
  attr_accessor :filename
  
  def initialize(value, filename)
    super(value)
    @filename = filename
    @generated = false
  end
  
  # Returns the value of this generator. If the value hasn't been created yet
  #  then it generates it and saves it.
  def value
    if not @generated
      @generated = true
      @value = generate_value
    end
    return @value
  end
  
  # The function that generates a string from the file given.
  def generate_value
    lines = []
    open(@filename, 'r') { |f| lines = f.readlines }
    
    output = [open_text]
    
    lines.each do |l|
      vals = l.split(';')
      output.push(val_processor(vals))
    end
    
    output.push(close_text)
    
    return output.join
  end
  
  # A line of text added before the file processing. Use for opening tags and
  #  such.
  def open_text
    ""
  end
  
  # A line of text added after the file processing. Use for closing tags and
  #  such.
  def close_text
    ""
  end
  
  # Runs for each line. Vals is an array of the values on the line. Use this
  #  function to process those vals and return a string to add to the output.
  def val_processor(vals)
    return vals.join
  end
end
