module Middleman; module AsciiDoc
  module DiagramProcessorExt
    def cache_dir parent
      if ENV.key? 'MM_ROOT'
        File.join ENV['MM_ROOT'], '.asciidoctor/diagram'
      else
        super
      end
    end

    ::Asciidoctor::Diagram::Extensions::DiagramBlockProcessor.send :prepend, self
    ::Asciidoctor::Diagram::Extensions::DiagramBlockMacroProcessor.send :prepend, self
  end
end; end
