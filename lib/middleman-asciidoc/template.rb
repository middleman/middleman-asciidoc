# Enhance the default template for AsciiDoc to make the Asciidoctor::Document
# instance accessible to the current page via the variable path
# `current_page.data.document`.
module Middleman; module AsciiDoc
  module Template
    DEFAULT_OPTIONS = { header_footer: false }

    def prepare
      opts = DEFAULT_OPTIONS.merge options
      if (ctx = middleman_context)
        attrs = opts[:attributes]
        attrs['outfile'] = outfile = ::File.join \
            (ctx.app.root_path.join ctx.app.config[:build_dir].to_s),
            ctx.current_page.destination_path
        attrs['outdir'] = opts[:to_dir] = ::File.dirname outfile
      end
      @document = ::Asciidoctor.load data, opts
      ctx.current_page.data.document = @document if ctx
      @output = nil
    end

    def evaluate scope, locals
      @output ||= @document.convert
    end

    def middleman_context
      if ::Middleman::TemplateContext === (ctx = options[:context])
        ctx
      end
    end
  end

  if (template_class = ::Tilt[:adoc])
    template_class.send :prepend, Template
  end
end; end
