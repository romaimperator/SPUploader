


class Page
  NEWLINE_TAG = "<newline>"
  
  # tag syntax: {name /} or {name}value{/name}
  # matches {name /} where $1 is 'name'
  TAG = /\{([^}\/ ]+)\s*\/\}/  
  # matches opening tag of {name}value{/name} where $1 is 'name'
  OPEN_TAG = /\{([^}\/ ]+)\}/
  # matches closing tag of {name}value{/name} where $1 is 'name'
  CLOSE_TAG = /\{\/([^}\/ ]+)\}/
  
  attr_accessor :name, :code, :file, :tags, :values
  
  def initialize(name, filename)
    @name = name
    @file = filename
    begin
      open(filename, 'r') { |f| @code = f.readlines }
    rescue
      puts "Could not initialize PageTemplate. Error opening #{filename}"
      exit 1
    end
    @tags, @values = parse_tags
  end
  
  # Returns the page code as a string with newlines represented as '<newline>'
  #def get_code_as_string
  #  return add_newline_tag(@code)
  #end
  
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
  #def add_replaceable_tag(t)
  #  if t.is_a?(Array)
  #    t.each { |tag| @tags.push(tag) unless is_replaceable_tag(tag) }
  #  else
  #    @tags.push(t) unless is_replaceable_tag(tag)
  #  end
  #end
  
  # Returns true if the tag is in the tags array
  #def is_replaceable_tag?(t)
  #  return @tags.include?(t)
  #end
  
  # Proceeds through all of the lines and pulls out the tags that exist and
  #  values accociated (if there are any) and returns the list of tags found and
  #  a hash of {tag => value} for tags that have values
  def parse_tags
    tags = []
    values = {}
    open_tags = []
    @code.each do |line|
      tags, values, open_tags = parse_line(line, tags, values, open_tags)
    end
    if not open_tags.empty?
      puts "Error: missing the following #{open_tags.size} closing tags"
      puts open_tags
      exit 1
    end
    return tags, values
  end
  
  # Checks the 'line' to see if it contains a tag. Then proceeds to handle
  #  depending if it is an opening tag, closing tag, or a placeholder tag.
  #  returns an array of tags, a hash containing the tags with values, an array
  #  of open tags
  def parse_line(line, tags, values, open_tags)
    if line.match(TAG)
      tags = handle_adding_tag($1, tags)
    elsif line.match(OPEN_TAG)
      open_tags.push($1)
      tags = handle_adding_tag($1, tags)
    elsif line.match(CLOSE_TAG)
      open_tags = handle_close_tag($1, open_tags)
    end
    
    values = handle_add_line_to_values(line, values, open_tags)
    
    return tags, values, open_tags
  end
  
  # Checks if the closing tag is expected and if so pops the tag off the stack
  #  and returns the stack
  def handle_close_tag(tag, open_tags)
    if open_tags.last == tag
      open_tags.pop
    else
      puts "Error: closing tag #{open_tags.first} expected but found #{tag}"
      exit 1
    end
    return open_tags
  end
  
  # Adds the line to any value that has an open tag except for when the line is
  #  the open tag for the value
  def handle_add_line_to_values(line, values, open_tags)
    line.match(OPEN_TAG)
    open_tags.each do |t|
      next if t == $1
      if values[t] == nil
        values[t] = line
      else
        values[t] += line
      end
    end
    return values
  end
  
  # Adds the given variable to the given array as long as it isn't already in
  #  the array and then returns the array. Used to add a tag.
  def handle_adding_tag(tag, tags)
    if tags.include?(tag)
      puts "Warning: duplicate tag #{tag} detected"
    else
      tags.push(tag)
    end
    return tags
  end
end
