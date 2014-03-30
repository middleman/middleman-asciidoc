# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-asciidoc/version"

Gem::Specification.new do |s|
  s.name = "middleman-asciidoc"
  s.version = Middleman::Asciidoc::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Dan Allen"]
  s.email = ["dan.j.allen@gmail.com"]
  s.homepage = "https://github.com/middleman/middleman-asciidoc"
  s.summary = %q{AsciiDoc support for Middleman}
  s.description = %q{AsciiDoc rendering and metadata support for Middleman}
  s.license = "MIT"
  s.files = `git ls-files -z`.split("\0")
  s.test_files = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]
  s.add_runtime_dependency("middleman-core", ["~> 3.2"])
  s.add_runtime_dependency("asciidoctor", ["~> 0.1.4"])
end
