
# Instead identify the tags from the HTML template using regex rather than
# requiring explicit regex.

# Tag format:
# {title /}
#
# {title}This is text to replace the title tag with{/title}



require 'Page'

class TemplatedPage < Page
  attr_accessor :template
  
  # Constructor taking a Page as the template
  def initialize(name, template, filename)
    super(name, template, filename)
    if template.is_a?(TemplatedPage)
      puts "Error: TemplatedPages cannot be templates"
      exit 1
    end
    @template = template
  end
  
  # Renders this template to the file
  def render_to_file
    open(@name + ".html", 'w') { |f| f.write(render) }
  end
  
  # Returns the rendered code as a string
  def render
    return generate_output(super)
  end
  
  # Returns a string and set @html to the string of the generated code from the
  #  templates
  def generate_output(values)
    #puts "values:'#{values.inspect}'"
    #puts "right:'#{values['right']}'"
    @html = ""
    create_output(values['root'], values)
    #puts "html:'#{@html}'"
    return @html
  end
  
  # Recursively proceeds through all tags substituting the values for the tags
  #  and returning the result
  def create_output(val, values)
    #puts "val:'#{val}'"
    if val.is_a?(String) then val = Generator.new(val) end
    if val.value == nil or val.value == ""
      return
    elsif val.value.match(TAG)
      create_output(values[$2], values)
      create_output(val.value.sub($1, ''), values)
    elsif match = val.value.match(VALUE_TEXT)
      @html += match[1]
      create_output(val.value.sub(match[1], ''), values)
    else
      return
    end
  end
  
end
