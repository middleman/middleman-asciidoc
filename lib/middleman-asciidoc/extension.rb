require 'asciidoctor'

module Middleman
  module AsciiDoc
    class AsciiDocExtension < ::Middleman::Extension
      option :asciidoc_attributes, [], 'AsciiDoc custom attributes (Array)'

      def initialize(app, options_hash={}, &block)
        super

        app.config.define_setting :asciidoc, {
          :safe => :safe,
          :backend => :html5,
          :attributes => %W(showtitle env=middleman env-middleman middleman-version=#{::Middleman::VERSION})
        }, 'AsciiDoc engine options (Hash)'
      end

      def after_configuration
        # QUESTION should base_dir be equal to docdir instead?
        app.config[:asciidoc][:base_dir] = app.source_dir
        app.config[:asciidoc][:attributes].concat(Array(options[:asciidoc_attributes]))
        app.config[:asciidoc][:attributes] << %(imagesdir=#{File.join((app.config[:http_prefix] || '/').chomp('/'), app.config[:images_dir])})
      end

      def manipulate_resource_list(resources)
        resources.each do |resource|
          path = resource.request_path
          next unless path.present? && File.extname(path) == '.adoc'

          # read the AsciiDoc header only to set page options and data
          # header values can be accessed via app.data.page.<name> in the layout
          doc = Asciidoctor.load_file path, :safe => :safe, :parse_header_only => true

          opts = {}
          if doc.attr? 'page-layout'
            case (layout = (doc.attr 'page-layout'))
            when '', 'false'
              opts[:layout] = false
            else
              opts[:layout] = layout
            end
          end
          opts[:layout_engine] = (doc.attr 'page-layout-engine') if (doc.attr? 'page-layout-engine')
          # TODO override attributes to set docfile, docdir, docname, etc
          # alternative is to set :renderer_options, which get merged into options by the rendering extension
          #opts[:attributes] = config[:asciidoc][:attributes].dup
          #opts[:attributes].concat %W(docfile=#{path} docdir=#{File.dirname path} docname=#{(File.basename path).sub(/\.adoc$/, '')})

          page = {}
          page[:title] = doc.doctitle
          page[:date] = (doc.attr 'date') unless (doc.attr 'date').nil?
          # TODO grab all the author information
          page[:author] = (doc.attr 'author') unless (doc.attr 'author').nil?

          resource.add_metadata options: opts, locals: { asciidoc: page }
        end
      end
    end
  end
end
