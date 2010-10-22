


class Page
  NEWLINE_TAG = "<newline>"
  
  attr_accessor :name, :code, :file, :tags
  
  def initialize(name, filename, code, tags)
    @name = name
    @file = filename
    @code = code
    @tags = tags
  end
  
  # Returns the page code as a string with newlines represented as '<newline>'
  def get_code_as_string
    return add_newline_tag(@code)
  end
  
  # Returns the string replacing '<newline>' with actual newlines
  def remove_newline_tag(s)
    return s.gsub(NEWLINE_TAG, "\n")
  end
  
  # Returns the string replacing newlines with the NEWLINE_TAG
  def add_newline_tag(s)
    return s.gsub("\n", NEWLINE_TAG)
  end
  
  # Adds the regex tag to the list of replaceable tags in this template
  #  also adds a list if the passed tag is an array of tags
  def add_replaceable_tag(t)
    if t.is_a?(Array)
      t.each { |tag| @tags.push(tag) unless is_replaceable_tag(tag) }
    else
      @tags.push(t) unless is_replaceable_tag(tag)
    end
  end
  
  # Returns true if the tag is in the tags array
  def is_replaceable_tag?(t)
    return @tags.include?(t)
  end
end
