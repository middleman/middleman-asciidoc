require 'asciidoctor'

module Middleman
  module AsciiDoc
    class AsciiDocExtension < ::Middleman::Extension
      option :asciidoc_attributes, [], 'AsciiDoc custom attributes (Array)'

      def initialize app, options_hash = {}, &block
        super

        app.config.define_setting :asciidoc, {
          safe: :safe,
          backend: :html5,
          attributes: ['env=middleman', 'env-middleman', %(middleman-version=#{::Middleman::VERSION})]
        }, 'AsciiDoc engine options (Hash)'
      end

      def after_configuration
        # QUESTION should base_dir be equal to docdir instead?
        app.config[:asciidoc][:base_dir] = app.source_dir.expand_path.to_s
        app.config[:asciidoc][:attributes].concat Array(options[:asciidoc_attributes])
        app.config[:asciidoc][:attributes] << %(imagesdir=#{File.join((app.config[:http_prefix] || '/').chomp('/'), app.config[:images_dir])})
        # QUESTION should we convert attributes to a map at this point?
      end

      def manipulate_resource_list(resources)
        default_page_layout = app.config[:layout] == :_auto_layout ? '' : app.config[:layout]
        asciidoctor_opts = app.config[:asciidoc].merge parse_header_only: true
        asciidoctor_opts[:attributes].unshift 'page-layout' # placeholder entry
        resources.each do |resource|
          next unless (path = resource.source_file).present? && (path.end_with? '.adoc')

          # read the AsciiDoc header only to set page options and data
          # header values can be accessed via app.data.page.<name> in the layout
          asciidoctor_opts[:attributes][0] = %(page-layout=#{resource.options[:layout] || default_page_layout}@)
          doc = Asciidoctor.load_file path, asciidoctor_opts

          opts = {}
          page = {}

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

          doc.attributes.each do |(key,val)|
            case key
            when 'doctitle'
              page[:title] = val
            when 'author', 'email', 'date'
              page[key.to_sym] = val
            when 'revdate'
              page[:date] ||= val
            else
              if (key.start_with? 'page-') && !(key.start_with? 'page-layout')
                page[key[5..-1].to_sym] = val
              end
            end
          end
          
          # QUESTION should we use resource.ext == doc.outfilesuffix instead?
          unless resource.destination_path.end_with? doc.outfilesuffix
            # NOTE we must use << or else the layout gets disabled
            resource.destination_path << doc.outfilesuffix
          end

          resource.add_metadata options: opts, page: page
        end
      end
    end
  end
end
