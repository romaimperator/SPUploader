#!/usr/bin/ruby -w

require 'PageTemplate'
require 'TemplatedPage'

p = PageTemplate.new('name', nil, 'test')
c = PageTemplate.new('sub', p, 'test2')
gc = TemplatedPage.new('grand', c, 'test3')

#puts "'p\n#{p.values.inspect}'"
#puts "'c\n#{c.values.inspect}'"
#puts "'gc\n#{gc.values.inspect}'"

#puts "'p\n#{p.tags.inspect}'"
#puts "'c\n#{c.tags.inspect}'"

puts gc.render
