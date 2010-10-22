

class Page
  NEWLINE_TAG = "<newline>"
  
  # tag syntax: {name /} or {name}value{/name}
  # matches {name /} where $1 is 'name'
  TAG = /\A(\{([^}\/ ]+)\s*\/\})/
  # matches opening tag of {name}value{/name} where $1 is 'name'
  OPEN_TAG = /\A(\{([^}\/ ]+)\})/
  # matches closing tag of {name}value{/name} where $1 is 'name'
  CLOSE_TAG = /\A(\{\/([^}\/ ]+)\})/
  # matches all text until a {
  VALUE_TEXT = /\A(([^{]|\s)+)(\{|\Z)/
  
  attr_accessor :name, :code, :file, :tags, :values, :html, :merged_values
  
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
    @html = ""
    @merged_values = {}
  end
  
  def write_html(html)
    @html = html
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
  
  # Adds the values found in 'template' to the matching tags in 'values' and
  #  returns the new values hash
  # TODO: unfortunately gonna be much more complicated
  #   -shouldn't be merged values
  #   -should produce the code stepping through the root value replacing tags
  #     that have values in 'template'
  #   -probably use regex to match {tag /} and replace with value
  #   -should output string of all merges
  #   -actually a structure of tags made at same time as parsing could assist
  def merge_template_values(template)
    @merged_values = @values.merge(template.values)
  end
  
  # Writes values into code returning the string created
  def merge_values_and_code
    puts get_tag_regex(values.keys[0])
  end
  
  # Produces regex to match a value opening tag from tag name
  def get_open_tag_regex(tag)
    return Regexp.new("\\{#{tag}\\}")
  end
  
  # Produces regex to match a value closing tag from tag name
  def get_close_tag_regex(tag)
    return Regexp.new("\\{/#{tag}\\}")
  end
  
  # Produces regex to match a non-value tag from tag name
  def get_tag_regex(tag)
    return Regexp.new("\\{#{tag} /\\}")
  end
  
  def get_open_tag(tag)
    return "{#{tag}}"
  end
  def get_close_tag(tag)
    return "{/#{tag}}"
  end
  def get_tag(tag)
    return "{#{tag} /}"
  end
  
  # Proceeds through all of the lines and pulls out the tags that exist and
  #  values accociated (if there are any) and returns the list of tags found and
  #  a hash of {tag => value} for tags that have values
  def parse_tags
    tags = []
    values = {}
    open_tags = ['root']
    @code.each do |line|
      tags, values, open_tags = parse_line(line, tags, values, open_tags)
    end
    #puts open_tags.inspect
    open_tags.slice!(0..-1)
    #puts open_tags.inspect
    if not open_tags.empty?
      puts "Error: missing the following #{open_tags.size} closing tags"
      puts open_tags.inspect
      exit 1
    end
    return tags, values
  end
  
  # Checks the 'line' to see if it contains a tag. Then proceeds to handle
  #  depending if it is an opening tag, closing tag, or a placeholder tag.
  #  returns an array of tags, a hash containing the tags with values, an array
  #  of open tags
  def parse_line(line, tags, values, open_tags)
    #puts "name:#{@name} line:'#{line}'"
    if line.match(TAG)
      tags = handle_adding_tag($2, tags)
      values = handle_add_to_top_open_tag(get_tag($2), open_tags, values)
    elsif line.match(OPEN_TAG)
      puts "pushing:#{$2}"
      open_tags.push($2)
      tags = handle_adding_tag($2, tags)
    elsif line.match(CLOSE_TAG)
      values, open_tags = handle_close_tag($2, values, open_tags)
    elsif line.match(VALUE_TEXT)
      values = handle_add_to_top_open_tag($1, open_tags, values)
    else
      puts "Error: didn't match '#{line}'"
      exit 1
    end
    
    whole = $1
    if line.sub(whole, '') != nil and line.sub(whole, '') != ""
      return parse_line(line.sub(whole,''), tags, values, open_tags)
    else    
      return tags, values, open_tags
    end
  end
  
  # Checks that there is a currently open tag before adding the current line
  #  to the value
  def handle_add_to_top_open_tag(line, open_tags, values)
    if not open_tags.empty?
      return handle_add_line_to_value(line, open_tags.last, values)
    else
      return values
    end
  end
  
  # Adds the string 'line' to the hash value of 't' in the hash 'values'
  def handle_add_line_to_value(line, t, values)
    if values[t] == nil
      values[t] = line
    else
      values[t] += line
    end
    return values
  end
  
  # Checks if the closing tag is expected and if so pops the tag off the stack
  #  and returns the stack
  def handle_close_tag(tag, values, open_tags)
    if open_tags.last == tag
      puts "poping:#{tag}"
      open_tags.pop
      values = handle_add_to_top_open_tag(get_tag(tag), open_tags, values)
      puts values.inspect
    else
      puts "Error: closing tag #{open_tags.first} expected but found #{tag}"
      exit 1
    end
    return values, open_tags
  end
  
  # Adds the line to any value that has an open tag except for when the line is
  #  the open tag for the value
  def handle_add_line_to_values(line, values, open_tags)
    #line.match(OPEN_TAG)
    open_tags.each do |t|
      #next if t == $1
      values = handle_add_line_to_value(line, t, values)
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
