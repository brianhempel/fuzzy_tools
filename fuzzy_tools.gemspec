# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fuzzy_tools/version"

Gem::Specification.new do |s|
  s.name        = "fuzzy_tools"
  s.version     = FuzzyTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Hempel"]
  s.email       = ["plasticchicken@gmail.com"]
  s.homepage    = "https://github.com/brianhempel/fuzzy_tools"
  s.summary     = %q{Easy, high quality fuzzy search in Ruby.}
  s.description = %q{Easy, high quality fuzzy search in Ruby.}

  s.files         = `git ls-files | grep --invert-match --extended-regexp '^(accuracy|performance)/'`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'RubyInline'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
end
