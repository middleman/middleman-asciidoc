# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'middleman-asciidoc/version'

Gem::Specification.new do |s|
  s.name = 'middleman-asciidoc'
  s.version = Middleman::AsciiDoc::VERSION
  s.summary = 'AsciiDoc support for Middleman'
  s.description = 'Converts AsciiDoc files in the source directory to HTML pages. Allows page data to be specified using AsciiDoc attributes defined in the document header (as an alternative to YAML front matter).'

  s.authors = ['Dan Allen']
  s.email = ['dan.j.allen@gmail.com']
  s.homepage = 'https://github.com/middleman/middleman-asciidoc'
  s.license = 'MIT'

  s.files = `git ls-files -z`.split "\0"
  s.test_files = `git ls-files -z -- {fixtures,features}/*`.split "\0"
  s.require_paths = ['lib']

  s.add_runtime_dependency 'middleman-core', '~> 4.0'
  s.add_runtime_dependency 'asciidoctor', '>= 1.5.0'
end
