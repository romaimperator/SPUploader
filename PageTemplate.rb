
require 'Page'

class PageTemplate < Page
  
  def initialize(name, filename)
    code = ""
    begin
      open(filename, 'r') { |f| code = f.readlines.join }
    rescue
      puts "Could not initialize PageTemplate. Error opening #{filename}"
      exit 1
    end
    super(name, filename, code, [])
  end
  
end
