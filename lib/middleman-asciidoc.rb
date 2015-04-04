require 'middleman-core'
require 'middleman-asciidoc/version'
require 'middleman-asciidoc/extension'

::Middleman::Extensions.register(:asciidoc, Middleman::AsciiDoc::AsciiDocExtension)
