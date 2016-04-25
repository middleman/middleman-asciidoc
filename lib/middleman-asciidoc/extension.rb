require 'asciidoctor' unless defined? Asciidoctor

module Middleman
  module AsciiDoc
    class AsciiDocExtension < ::Middleman::Extension
      DEFAULT_ATTRIBUTES = ['env=middleman', 'env-middleman', %(middleman-version=#{::Middleman::VERSION})]
      option :attributes, [], 'Custom AsciiDoc attributes (Array)'
      option :backend, :html5, 'Moniker used to select output format (Symbol)'
      option :base_dir, nil, 'Base directory to use for the current AsciiDoc document; if nil, defaults to docdir (String)'
      option :safe, :safe, 'Safe mode level (Symbol)'

      def initialize app, options_hash = {}, &block
        super
        app.config.define_setting :asciidoc, {}, 'AsciiDoc processor options (Hash)'
        # NOTE support global :asciidoc_attributes setting for backwards compatibility
        app.config.define_setting :asciidoc_attributes, [], 'Custom AsciiDoc attributes (Array)'
      end

      # NOTE options passed to activate take precedence (e.g., activate :asciidoc, attributes: ['foo=bar'])
      def after_configuration
        if app.config.setting(:asciidoc).value_set?
          warn 'Using `set :asciidoc` to define options is deprecated. Please define options on `activate :asciidoc` instead.'
        end
        app.config[:asciidoc].tap do |cfg|
          (cfg[:attributes] ||= []).unshift %(imagesdir=#{File.join((app.config[:http_prefix] || '/').chomp('/'), app.config[:images_dir])}@)
          cfg[:attributes].unshift *DEFAULT_ATTRIBUTES
          if options.setting(:attributes).value_set?
            cfg[:attributes].concat Array(options[:attributes])
          elsif app.config.setting(:asciidoc_attributes).value_set?
            cfg[:attributes].concat Array(app.config[:asciidoc_attributes])
          end
          cfg[:base_dir] = (dir = options[:base_dir]) ? dir.to_s : dir if options.setting(:base_dir).value_set?
          # QUESTION ^ should we call expand_path on :base_dir if non-nil?
          cfg[:backend] = options[:backend] if options.setting(:backend).value_set?
          cfg[:backend] = (cfg[:backend] || :html5).to_sym
          cfg[:safe] = options[:safe] if options.setting(:safe).value_set?
          cfg[:safe] = (cfg[:safe] || :safe).to_sym
        end
      end

      def manipulate_resource_list(resources)
        default_page_layout = app.config[:layout] == :_auto_layout ? '' : app.config[:layout]
        asciidoctor_opts = app.config[:asciidoc].merge parse_header_only: true
        asciidoctor_opts[:attributes].unshift 'page-layout' # placeholder entry
        use_docdir_as_base_dir = asciidoctor_opts[:base_dir].nil?
        resources.each do |resource|
          next unless (path = resource.source_file).present? && (path.end_with? '.adoc')

          # read the AsciiDoc header only to set page options and data
          # header values can be accessed via app.data.page.<name> in the layout
          asciidoctor_opts[:attributes][0] = %(page-layout=#{resource.options[:layout] || default_page_layout}@)
          asciidoctor_opts[:base_dir] = (::File.dirname path) if use_docdir_as_base_dir
          doc = Asciidoctor.load_file path, asciidoctor_opts
          opts = {}
          page = {}

          opts[:base_dir] = asciidoctor_opts[:base_dir] if use_docdir_as_base_dir

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
