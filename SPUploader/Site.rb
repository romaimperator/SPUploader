require 'SPUploader/PageTemplate'
require 'SPUploader/TemplatedPage'
require 'SPUploader/RootTemplate'

# This class is a wrapper for all of the templating stuff. It is designed to 
#  provide a more simple way to interact with the templating system than using
#  the classes directly.

class Site
  ROOT_NAME = 'root'
  
  def initialize(name, site_path='')
    @name = name # Just a simple name for the site
    @pages = {}
    @site_path = site_path # The root remote path.
  end
  
  
  # Sets the root page to a template from the file given by 'filename'. The
  #  templates name is set to be 'root'.
  def set_root_template(filename)
    if @pages[ROOT_NAME] != nil
      puts "Warning: the root template is being overwritten. If this is what" \
         + " is desired than you can ignore this message."
    end
    @pages[ROOT_NAME] = RootTemplate.new(ROOT_NAME, filename)
  end
  
  
  # Adds the a page template to the site with the given 'name', parent and 
  #  filename. If no parent template name is specified, 'root' is assumed.
  def add_page_template(name, filename, parent=ROOT_NAME)
    if template_exists?(parent)
      @pages[name] = PageTemplate.new(name, @pages[parent], filename)
    else
      puts "Warning: could not add page template #{name} because the parent " \
         + "template #{parent} is not in the site."
    end
  end
  
  
  # Removes the page template with the given 'name'. WARNING: Does not validate
  #  the site and does not fix template linking errors. Use with caution because
  #  it can break your site if you leave in pages with the removed template as
  #  a parent.
  def remove_page_template(name)
    if is_a_template?(name)
      @pages[name] = nil
    else
      puts "Warning: can't remove template #{name} because it's not a template."
    end
    # TODO: decide about checking and/or warning about broken template strings
    #       possibly even repairing by pointing children of removed at removed's
    #       parent
  end
  
  
  # Adds a renderable page to the site with the given name, parent, and
  #  filename. Assumes root if no parent specified. Also checks if the parent
  #  template exists.
  def add_page(name, filename, parent=ROOT_NAME, file_path='')
    if template_exists?(parent)
      @pages[name] = TemplatedPage.new(name, @pages[parent], filename,file_path)
    else
      puts "Warning: could not add page #{name} because the parent template" \
         + " #{parent} is not in the site."
    end
  end
  
  
  # Removes the page with the given 'name'. Unlike the page template remove,
  #  there should be no issues with this since these pages cannot be used as
  #  templates.
  def remove_page(name)
    if is_a_page?(name)
      @pages[name] = nil
    else
      puts "Warning: cannot remove the page #{name} because it is not a page."
    end
  end
  
  
  # Changes the template to have the new specified values. If the name changes,
  #  there should be no backend changes because the templates refer to each
  #  other by object reference not name. Only in the user space should this
  #  matter. If a newname is not given then use the same name.
  def update_template(name, filename, newname=name, parent=ROOT_NAME, 
                      file_path='')
    if is_a_template?(name)
      if name != newname 
        puts "Warning: the name of the template #{name} has changed. Remember" \
           + " to refer to this new name #{newname} instead."
      end
      @pages[name] = PageTemplate.new(newname, 
                                      @pages[parent], 
                                      filename, 
                                      file_path)
    else
      puts "Warning: can't update template #{name} because it's not a template."
    end
  end
  
  
  # Changes the page to have the new specified values. If a newname is not
  #  given then use the same name.
  def update_page(name, filename, newname=name, parent=ROOT_NAME)
    if is_a_page?(name)
      if name != newname
        puts "Warning: the name of the template #{name} has changed. Remember" \
           + " to refer to this new name #{newname} instead."
      end
      @pages[name] = TemplatedPage.new(newname, @pages[parent], filename)
    else
      puts "Warning: can't update page #{name} because it's not a page."
    end
  end
  
  
  # Renders all of the pages to files.
  def render_to_file(site_path=@site_path)
    @pages.each do |p|
      p.render_to_file(site_path)
    end
  end
  
  
  # Renders all of the pages to the remote site.
  def render_to_site(site_path=@site_path)
    @pages.each do |p|
      p.render_to_site(site_path)
    end
  end
  
  
  # Sets the path of the root of the site.
  def set_site_path(site_path)
    @site_path = site_path
  end
  
  
  # Adds a generator to the specified page or templated page for the given tag.
  def add_generator(name, tag_gen_hash)
    if template_exists?(name)
      tag_gen_list.each do |t, g|
        @pages[name].add_generator(t, g)
      end
    else
      puts "Warning: unable to add generator because the page or template " \
         + "#{name} is not part of the site."
    end
  end
  
  
  # Returns true if there is a template with the specified name
  def template_exists?(name)
    return @pages[name] != nil
  end
  
  
  # Returns true if the template with the given name is a template or not. In
  #  other words it cannot be a TemplatedPage.
  def is_a_template?(name)
    if template_exists?(name)
      return @pages[name].is_a?(PageTemplate)
    else
      puts "Warning: cannot check if the template #{name} is a page because " \
         + "it doesn't exist in the site."
      return false
    end
  end
  
  
  # Returns true if the page with the given name is a page or not. In other
  #  words it checks if the value is a TemplatedPage.
  def is_a_page?(name)
    if template_exists?(name)
      return @pages[name].is_a?(TemplatedPage)
    else
      puts "Warning: cannot check if the page #{name} is a page because it " \
         + "doesn't exist in the site."
      return false
    end
  end
end
