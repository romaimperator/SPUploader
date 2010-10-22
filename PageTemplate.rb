
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
    if has_child?
      @children.each do |c|
        merged = render_child(self, c)
        merge_template_values(merged)
        #puts html
      end
    end
    #@children.each do |c|
   #   next unless c.is_a?(PageTemplate)
    #  rend
#      merge_template_hash(@values, c)
      #merge_template_values(c)
      #write_html_to_file(c.file)
    #end
  end
  
  def render_child(parent, child)
    if parent == nil or child == nil
      return
    end
    if child.has_child?
      child.children.each do |c|
        puts "calling child..."
        render_child(child, c)
      end
    end
    puts "rendering parent #{parent.name} and child #{child.name}..."
    return merge_template_hash(parent, child)
  end
    
  # Adds a template child
  def add_child(template)
    @children.push(template) unless @children.include?(template)
  end
  
  def has_child?
    return !@children.empty?
  end
end
