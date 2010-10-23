#!/usr/bin/ruby -w

require 'PageTemplate'
require 'TemplatedPage'
require 'SSVGenerator'

class TableGenerator < SSVGenerator
  def iniitialize(value, filename)
    super(value, filename)
  end
  
  def open_text
    return "<div id=\"time_table\"><table>\n\t<tr>\n\t\t<td>Date</td>\n\t\t" + \
      "<td>Length (min)</td>\n\t\t<td>Members Present</td>\n\t\t<td>Results" + \
      "</td>\n\t</tr>\n"
  end
  
  def val_processor(vals)
    puts "vals:#{vals}"
    date, len, peeps, done = vals
    return "\t<tr>\n\t\t<td>" + date + "</td>\n\t\t<td>" + len + \
      "</td>\n\t\t<td>" + peeps + "</td>\n\t\t<td>" + done.chop + \
      "</td>\n\t</tr>\n"
  end
  
  def close_text
    return "</table></div><!--/timetable-->"
  end
end

gen = TableGenerator.new("", 'table.csv')

p = PageTemplate.new('name', nil, 'test')
c = PageTemplate.new('sub', p, 'test2')
gc = TemplatedPage.new('grand', c, 'test3')

p.add_generator('table', gen)

#puts "'p\n#{p.values.inspect}'"
#puts "'c\n#{c.values.inspect}'"
#puts "'gc\n#{gc.values.inspect}'"

#puts "'p\n#{p.tags.inspect}'"
#puts "'c\n#{c.tags.inspect}'"

puts gc.render
