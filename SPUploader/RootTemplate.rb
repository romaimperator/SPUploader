require File.dirname(__FILE__) + '/PageTemplate'

# This class provides an abstraction for the end user of how a root template is
#  represented. A PageTemplate is only a root because the parent template
#  variable is nil.

class RootTemplate < PageTemplate
  def initialize(name, filename)
    super(name, nil, filename)
  end
end
