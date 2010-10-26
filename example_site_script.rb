#!/usr/bin/ruby -w

require 'SPUploader'

# This is provided to be an example of the build script of a simple website.

# These are required for the sftp library to upload the files to a remote
#  server.
HOSTNAME = ""
USERNAME = ""
PASSWORD = ""

# This is an example of an implementation of an SSVGenerator. This takes values
#  in a text file and creates an HTML table from them to replace a tag in the
#  template.
class TableGenerator < SSVGenerator
  def initialize(name, filename)
    super("", filename)
    @name = name
  end
  
  
  # Here the function produces output for each line from the SSV by using the
  #  values provided in vals.
  def val_processor(vals)
    date, len, peeps, done = vals
    if peeps.include?(@name)
      return "\t<tr>\n\t\t<td>" + date + "</td>\n\t\t<td>" + len + \
        "</td>\n\t\t<td>" + peeps + "</td>\n\t\t<td>" + done.chop + \
        "</td>\n\t</tr>\n"
    else
      return ""
    end
  end
  
  
  def close_text
    return "</table>"
  end
  
  
  def open_text
    return "<table>\n\t<tr>\n\t\t<td>Date</td>\n\t\t<td>Length (min)</td>" + \
      "\n\t\t<td>Members Present</td>\n\t\t<td>Results</td>\n\t</tr>\n"
  end
end

# Here the generator is instantiated. The name used is the name of the person
#  so that only times he/she was present is the row added to the table.
dan_table = TableGenerator.new('Dan', 'table.ssv')
brett_table = TableGenerator.new('Brett', 'table.ssv')

# Here the page template tree is created.
#  This particular site has the following template structure:
#
#                   root
#                    |
#                 user_page
#                /         \
#            dan_page   brett_page
#
#  In this case, only the dan_page and brett_page are renderable.

# NOTE: the '.part' is not required for template files. Any file name will do.
#  '.part' is just my own usage so I know that it is not a complete file.
#  This is the root page
root = RootTemplate.new('root', 'root.part')

#  This is a subclass of templates that I am using to represent all user pages.
user_page = PageTemplate.new('user_page', root, 'user_page.part')

#  These are the individual user pages.
dan_page = TemplatedPage.new('dan', user_page, 'dan.part', '')
brett_page = TemplatedPage.new('brett', user_page, 'brett.part', '')

# Here the generator is hooked to the tag from the template file.
dan_page.add_generator('table', dan_table)
brett_page.add_generator('table', brett_table)

# Here the pages are rendered to a file. This process involves merging all the
#  templates together and replacing the tags with the values from either the
#  file or such as in this case, generators.
dan_page.render_to_file
brett_page.render_to_file
