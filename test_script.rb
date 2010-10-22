#!/usr/bin/ruby -w

require 'PageTemplate'

p = PageTemplate.new('name', 'test')
c = PageTemplate.new('sub', 'test2')
gc = PageTemplate.new('grand', 'test3')
p.add_child(c)
c.add_child(gc)

puts "'p\n#{p.values.inspect}'"
puts "'c\n#{c.values.inspect}'"
puts "'gc\n#{gc.values.inspect}'"

#puts "'p\n#{p.tags.inspect}'"
#puts "'c\n#{c.tags.inspect}'"

p.render
