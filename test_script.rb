#!/usr/bin/ruby -w

require 'PageTemplate'
require 'TemplatedPage'
require 'SSVGenerator'

class TableGenerator < SSVGenerator

  def initialize(name, filename)
    puts name
    super("", filename)
    @name = name
  end
  
  def val_processor(vals)
    #puts "vals:#{vals}"
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
    return "</table></div><!--/timetable-->"
  end
  
  def open_text
    return "<div id=\"time_table\"><table>\n\t<tr>\n\t\t<td>Date</td>\n\t\t" + \
      "<td>Length (min)</td>\n\t\t<td>Members Present</td>\n\t\t<td>Results" + \
      "</td>\n\t</tr>\n"
  end
end

gen = TableGenerator.new('Dan', 'table.csv')

p = PageTemplate.new('name', nil, 'template.part')
c = PageTemplate.new('sub', p, 'user_page.part')
gc = TemplatedPage.new('grand', c, 'dan.part')

gc.add_generator('table', gen)

#puts "'p\n#{p.values.inspect}'"
#puts "'c\n#{c.values.inspect}'"
#puts "'gc\n#{gc.values.inspect}'"

#puts "'p\n#{p.tags.inspect}'"
#puts "'c\n#{c.tags.inspect}'"

puts gc.render
