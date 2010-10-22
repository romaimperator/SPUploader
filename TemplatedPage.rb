
# Instead identify the tags from the HTML template using regex rather than
# requiring explicit regex.

# Tag format:
# {title /}
#
# {title}This is text to replace the title tag with{/title}



require 'Page'

class TemplatedPage < Page
  attr_accessor :sub_page, :tag_list
  
  # Constructor taking a Page as the template
  def initialize(name, template, filename)
    code = ""
    begin
      open(filename, 'r') { |f| code = f.readlines.join }
    rescue
      puts "Could not initialize TemplatedPage. Error opening #{filename}"
      exit 1
    end
    super(name, filename, code, [])
    @sub_page = []
    @tag_list = {}
  end
  
  # Merges the page with the template and any sub pages returning the string of 
  #  HTML code with given replacements for the tags. Skips over tags that are in
  #  the replaceable list and not passed in the hash.
  def render
    temp_code = get_code_as_string()
    
    @tag_list.each do |tag, val|
      if @tags.include?(tag)
        temp_code.gsub!(tag, val)
      end
    end
    return remove_newline_tag(temp_code)
  end
  
  # Returns the HTML of a link given a file with full path and the text to show 
  #  on the link
  def createLink(file, text)
    return "<a href=\"" + file + "\" target=\"_blank\">" + text + "</a>"
  end
  
  # Returns the first match of regex, r, in a string, s
  #  note: this replaces newlines with '<newline>'
  def getMatchFromString(s, r)
    s = s.gsub("\n", "<newline>")
    if (s.match(r))
      return $1
    end
  end

  # Returns the first match of regex, r, in the file, filename
  def getMatchFromFile(filename, r)
    lines = []
    open(filename, 'r') { |f| lines = f.readlines }
    lines = lines.join
    return getMatchFromString(lines, r)
  end
end
