require 'PageTemplate'

class RootTemplate < PageTemplate
  def initialize(name, filename)
    super(name, nil, filename)
  end
end
