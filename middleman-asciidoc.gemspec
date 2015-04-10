# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'middleman-asciidoc/version'

Gem::Specification.new do |s|
  s.name = 'middleman-asciidoc'
  s.version = Middleman::AsciiDoc::VERSION
  s.platform = Gem::Platform::RUBY

  s.summary = 'AsciiDoc support for Middleman'
  s.description = 'AsciiDoc rendering and metadata support for Middleman'

  s.authors = ['Dan Allen']
  s.email = ['dan.j.allen@gmail.com']
  s.homepage = 'https://github.com/middleman/middleman-asciidoc'
  s.license = 'MIT'

  s.files = `git ls-files -z`.split "\0"
  s.test_files = `git ls-files -z -- {fixtures,features}/*`.split "\0"
  s.require_paths = ['lib']

  s.add_runtime_dependency 'middleman-core', ['>= 4.0.0.alpha.0']
  s.add_runtime_dependency 'asciidoctor', '~> 1.5.2'
end
