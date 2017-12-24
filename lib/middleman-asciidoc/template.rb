# Enhance the default template for AsciiDoc to make the Asciidoctor::Document
# instance accessible to the current page via the variable path
# `current_page.data.document`.
module Middleman; module AsciiDoc
  module Template
    DEFAULT_OPTIONS = { header_footer: false }

    def prepare
      @document = ::Asciidoctor.load data, (DEFAULT_OPTIONS.merge options)
      if ::Middleman::TemplateContext === (ctx = options[:context])
        ctx.current_page.data.document = @document
      end
      @output = nil
    end

    def evaluate scope, locals
      @output ||= @document.convert
    end
  end

  if (template_class = ::Tilt['adoc'])
    template_class.send :prepend, Template
  end
end; end
