
require 'Page'

class PageTemplate < Page
  attr_accessor :parent, :children
  
  def initialize(name, filename)    
    super(name, filename)
    @parent = nil
    @children = []
  end
  
  # Generates the HTML for this template and all sub templates.
  def render
    @children.each do |c|
      next unless c.is_a?(PageTemplate)
      merge_template_values(c)
      puts "'#{@merged_values.inspect}'"
      merge_values_and_code()
    end
  end
  
  def add_child(template)
    @children.push(template) unless @children.include?(template)
  end
end
