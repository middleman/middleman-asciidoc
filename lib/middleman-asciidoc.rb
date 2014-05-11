require 'middleman-core'
require 'middleman-asciidoc/version'

Middleman::Extensions.register :asciidoc do
  require 'middleman-asciidoc/extension'
  Middleman::AsciiDoc::AsciiDocExtension
end
