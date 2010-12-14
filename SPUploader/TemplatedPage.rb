require 'SPUploader/Page'
require 'SPUploader/SftpUploader'

# This class is the leaf node of a template tree. Each page on the site will
#  require one of these. The page has the functionality to upload the rendered
#  page directly to a remote site. If this is not needed, just pass "" for the
#  remote_path variable to the constructor and don't called render_to_site.
class TemplatedPage < Page
  include SftpUploader
  
  attr_accessor :template, :remote_path
  
  # Constructor taking a Page as the template
  def initialize(name, template, filename, remote_path)
    super(name, template, filename)
    if template.is_a?(TemplatedPage)
      puts "Error: TemplatedPages cannot be templates"
      exit 1
    end
    @template = template
    @remote_path = remote_path
  end
  
  
  # Renders this template to a file on the remote server
  def render_to_site(remote_site_path)
    write_string_to_remote_file(@name + ".html", 
                                render,
                                remote_site_path + @remote_path)
  end
  
  
  # Renders this template to the file
  def render_to_file(remote_site_path)
    open(@remote_path + @name + ".html", 'w') { |f| f.write(render) }
  end
  
  
  # Returns the rendered code as a string
  def render
    return generate_output(@values)
  end
  
  
  # Returns a string and set @html to the string of the generated code from the
  #  templates
  def generate_output(values)
    @html = ""
    create_output(values['root'], values)
    return @html
  end
  
  
  # Recursively proceeds through all tags substituting the values for the tags
  #  and returning the result
  def create_output(val, values)
    if val.is_a?(String) then val = Generator.new(val) end
    if val.value == nil or val.value == ""
      return
    elsif val.value.match(TAG)
      create_output(values[$2], values)
      create_output(val.value.sub($1, ''), values)
    elsif match = val.value.match(VALUE_TEXT)
      @html += match[1]
      create_output(val.value.sub(match[1], ''), values)
    elsif match = val.value.match(BRACE_TEXT)
      @html += match[1]
      create_output(val.value.sub(match[1], ''), values)
    else
      return
    end
  end  
end
