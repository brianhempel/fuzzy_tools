$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'fuzzy'

Book = Struct.new(:title, :author)
