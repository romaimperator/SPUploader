#!/usr/bin/ruby -w

require 'PageTemplate'

p = PageTemplate.new('name', 'test')
c = PageTemplate.new('sub', 'test2')
p.add_child(c)

puts "'p\n#{p.values.inspect}'"
puts "'c\n#{c.values.inspect}'"

puts "'p\n#{p.tags.inspect}'"
puts "'c\n#{c.tags.inspect}'"

p.render
