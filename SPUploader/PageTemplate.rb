require 'SPUploader/Page'

# This class represents all templates for the pages. There is a special version,
#  RootTemplate, is the root of the template tree. This only exists so that
#  this kind of template can be identified and cannot directly produce output
#  from the template system.

class PageTemplate < Page
  def initialize(name, template, filename)    
    super(name, template, filename)
  end
end
