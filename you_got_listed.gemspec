# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "you_got_listed/version"

Gem::Specification.new do |s|
  s.name = %q{you_got_listed}
  s.authors = ["Tom Cocca"]
  s.date = %q{2011-04-11}
  s.description = %q{Ruby API wrapper for yougotlistings.com built with httparty}
  s.email = %q{tom.cocca@gmail.com}
  s.homepage = %q{http://github.com/tcocca/you_got_listed}
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{ruby api wrapper for you got listings}

  s.version = YouGotListed::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_ruby_version     = '>= 2.0.0'

  s.add_dependency "activesupport", ">= 3"
  s.add_dependency "httparty", "~> 0.12.0"
  s.add_dependency "rash", "~> 0.4.0"
  s.add_dependency "will_paginate", ">= 3"
  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "rspec", ">= 2.5.0"
  s.add_development_dependency "webmock", ">= 1.6.2"
  s.add_development_dependency "vcr", ">= 1.8.0"

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
