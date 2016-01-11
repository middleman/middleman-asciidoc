require 'asciidoctor'

module Middleman
  module AsciiDoc
    class AsciiDocExtension < ::Middleman::Extension
      option :asciidoc_attributes, [], 'AsciiDoc custom attributes (Array)'

      def initialize(app, options_hash={}, &block)
        super

        app.config.define_setting :asciidoc, {
          safe: :safe,
          backend: :html5,
          attributes: ['env=middleman', 'env-middleman', %(middleman-version=#{::Middleman::VERSION})]
        }, 'AsciiDoc engine options (Hash)'
      end

      def after_configuration
        # QUESTION should base_dir be equal to docdir instead?
        app.config[:asciidoc][:base_dir] = app.source_dir
        app.config[:asciidoc][:attributes].concat(Array(options[:asciidoc_attributes]))
        app.config[:asciidoc][:attributes] << %(imagesdir=#{File.join((app.config[:http_prefix] || '/').chomp('/'), app.config[:images_dir])})
      end

      def manipulate_resource_list(resources)
        default_page_layout = app.config[:layout] == :_auto_layout ? '' : app.config[:layout]
        resources.each do |resource|
          next unless (path = resource.source_file).present? && (::File.extname path) == '.adoc'

          # read the AsciiDoc header only to set page options and data
          # header values can be accessed via app.data.page.<name> in the layout
          doc = ::Asciidoctor.load_file path,
            safe: :safe,
            parse_header_only: true,
            attributes: { 'page-layout' => %(#{resource.options[:layout] || default_page_layout}@) }
          opts = {}

          # NOTE page layout value cascades from site config -> front matter -> page-layout header attribute
          if doc.attr? 'page-layout'
            if (layout = doc.attr 'page-layout').empty?
              opts[:layout] = :_auto_layout
            else
              opts[:layout] = layout
            end
            opts[:layout_engine] = doc.attr 'page-layout-engine' if doc.attr? 'page-layout-engine'
          else
            opts[:layout] = false
            opts[:header_footer] = true
          end

          # TODO override attributes to set docfile, docdir, docname, etc
          # alternative is to set :renderer_options, which get merged into options by the rendering extension
          #opts[:attributes] = config[:asciidoc][:attributes].dup
          #opts[:attributes].concat %W(docfile=#{path} docdir=#{File.dirname path} docname=#{(File.basename path).sub(/\.adoc$/, '')})

          page = {}
          page[:title] = doc.doctitle
          page[:date] = (doc.attr 'date') unless (doc.attr 'date').nil?
          # TODO grab all the author information
          page[:author] = (doc.attr 'author') unless (doc.attr 'author').nil?
          
          # QUESTION should we use resource.ext == '.html' instead?
          unless resource.destination_path.end_with? '.html'
            # NOTE we must use << or else the layout gets disabled
            resource.destination_path << '.html'
          end

          resource.add_metadata options: opts, locals: { asciidoc: page }
        end
      end
    end
  end
end
