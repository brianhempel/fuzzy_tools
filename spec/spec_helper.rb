$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'fuzzy_tools'

Book = Struct.new(:title, :author)
