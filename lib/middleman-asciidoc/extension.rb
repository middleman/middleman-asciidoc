require 'asciidoctor' unless defined? Asciidoctor

module Middleman
  module AsciiDoc
    class AsciiDocExtension < ::Middleman::Extension
      # run after front matter (priority: 20) is processed and before other third-party extensions (priority: 50)
      self.resource_list_manipulator_priority = 30

      IMPLICIT_ATTRIBUTES = {
        'env' => 'site',
        'env-site' => '',
        'site-gen' => 'middleman',
        'site-gen-middleman' => '',
        'builder' => 'middleman',
        'builder-middleman' => '',
        'middleman-version' => ::Middleman::VERSION
      }

      AttributeReferenceRx = /\\?\{(\w+(?:[\-]\w+)*)\}/

      option :attributes, [], 'Custom AsciiDoc attributes (Hash or Array)'
      option :backend, :html5, 'Moniker used to select output format (Symbol)'
      option :base_dir, nil, 'Base directory to use for the current AsciiDoc document; if nil, defaults to docdir (String)'
      option :safe, :safe, 'Safe mode level (Symbol)'

      def initialize app, options_hash = {}, &block
        super
        app.config.define_setting :asciidoc, {}, 'AsciiDoc processor options (Hash)'
        # NOTE support global :asciidoc_attributes setting for backwards compatibility
        app.config.define_setting :asciidoc_attributes, [], 'Custom AsciiDoc attributes (Hash or Array)'
      end

      # NOTE options passed to activate take precedence (e.g., activate :asciidoc, attributes: ['foo=bar'])
      def after_configuration
        if app.config.setting(:asciidoc).value_set?
          warn 'Using `set :asciidoc` to define options is deprecated. Please define options on `activate :asciidoc` instead.'
        end
        app.config[:asciidoc].tap do |cfg|
          attributes = {
            'site-root' => app.root.to_s,
            'site-source' => app.source_dir.to_s,
            'site-destination' => (dest = (app.root_path.join app.config[:build_dir]).to_s),
            'site-environment' => app.environment.to_s
          }.merge IMPLICIT_ATTRIBUTES
          # NOTE handles deprecated `set :asciidoc, attributes: ...`
          attributes = merge_attributes cfg[:attributes], attributes if cfg.key? :attributes
          # NOTE handles `activate :asciidoc, attributes: ...`
          if options.setting(:attributes).value_set?
            attributes = merge_attributes options[:attributes], attributes
          # NOTE handles `set :asciidoc_attributes ...`
          elsif app.config.setting(:asciidoc_attributes).value_set?
            attributes = merge_attributes options[:asciidoc_attributes], attributes
          end
          imagesdir = if attributes.key? 'imagesdir'
            attributes['imagesdir']
          else
            attributes['imagesdir'] = %(#{::File.join ((app.config[:http_prefix] || '').chomp '/'), app.config[:images_dir]}@)
          end
          if imagesdir && !(attributes.key? 'imagesoutdir') && (imagesdir.start_with? '/')
            attributes['imagesoutdir'] = ::File.join dest, (imagesdir.chomp '@')
          end
          cfg[:attributes] = attributes
          cfg[:base_dir] = (dir = options[:base_dir]) ? dir.to_s : dir if options.setting(:base_dir).value_set?
          # QUESTION ^ should we call expand_path on :base_dir if non-nil?
          cfg[:backend] = options[:backend] if options.setting(:backend).value_set?
          cfg[:backend] = (cfg[:backend] || :html5).to_sym
          cfg[:safe] = options[:safe] if options.setting(:safe).value_set?
          cfg[:safe] = (cfg[:safe] || :safe).to_sym
        end
      end

      def manipulate_resource_list resources
        default_page_layout = app.config[:layout] == :_auto_layout ? '' : app.config[:layout]
        asciidoc_opts = app.config[:asciidoc].merge parse_header_only: true
        asciidoc_opts[:attributes] = (asciidoc_attrs = asciidoc_opts[:attributes].merge 'skip-front-matter' => '')
        use_docdir_as_base_dir = asciidoc_opts[:base_dir].nil?
        resources.each do |resource|
          next unless !resource.ignored? && (path = resource.source_file).present? && (path.end_with? '.adoc')

          # read AsciiDoc header only to set page options and data
          # header values can be accessed via app.data.page.<name> in the layout
          asciidoc_attrs['page-layout'] = %(#{resource.options[:layout] || default_page_layout}@)
          asciidoc_opts[:base_dir] = ::File.dirname path if use_docdir_as_base_dir
          doc = Asciidoctor.load_file path, asciidoc_opts
          opts = {}
          page = {}

          opts[:base_dir] = asciidoc_opts[:base_dir] if use_docdir_as_base_dir

          if (doc.attr? 'page-ignored') && !(doc.attr? 'page-ignored', 'false')
            resource.ignore!
            next
          end

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

          page[:title] = doc.doctitle if doc.header?
          ['author', 'email'].each do |key|
            page[key.to_sym] = doc.attr key if doc.attr? key
          end
          if !(page.key? :date) && (doc.attr? 'revdate')
            begin
              page[:date] = ::DateTime.parse(doc.attr 'revdate').to_time
            rescue
            end
          end

          unless (adoc_front_matter = doc.attributes.each_with_object({}) {|(key, val), accum|
                if (page_variable_name = derive_page_variable_name key)
                  accum[page_variable_name] = ::String === val ? (parse_yaml_value val) : val
                end
              }).empty?
            page.update adoc_front_matter
          end

          unless resource.ext == doc.outfilesuffix
            # NOTE we must use << or else the layout gets disabled
            resource.destination_path << doc.outfilesuffix
          end

          resource.add_metadata options: opts, page: page
        end
      end

      def merge_attributes attrs, initial = {}
        if (is_array = ::Array === attrs) || ::Hash === attrs
          attrs.each_with_object(initial) {|entry, new_attrs|
            key, val = is_array ? ((entry.split '=', 2) + ['', ''])[0..1] : entry
            if key.start_with? '!'
              new_attrs[key[1..-1]] = nil
            elsif key.end_with? '!'
              new_attrs[key.chop] = nil
            else
              new_attrs[key] = val ? (resolve_attribute_refs val, new_attrs) : nil
            end
          }
        else
          initial
        end
      end

      def resolve_attribute_refs text, attrs
        if text.empty?
          text
        elsif text.include? '{'
          text.gsub(AttributeReferenceRx) { ($&.start_with? '\\') ? $&[1..-1] : ((attrs.fetch $1, $&).to_s.chomp '@') }
        else
          text
        end
      end

      # Derive the page variable name from the specified attribute name.
      #
      # Returns the page variable name as a [String] or nothing if the attribute name is not the name of a page
      # attribute.
      def derive_page_variable_name attribute_name
        if attribute_name != 'page-layout' && attribute_name != 'page-layout-engine' && attribute_name != 'page-ignored' &&
            (attribute_name.start_with? 'page-')
          attribute_name.slice 5, attribute_name.length
        end
      end

      # Parse the specified value as a single-line YAML value.
      #
      # Attempt to parse the specified String value as though it's a single-line YAML value (i.e., the value part of a
      # YAML key/value pair). If the value fails to parse, wrap the value in single quotes (after escaping any single
      # quotes in the value) and parse it as a character sequence. If the value is empty, return an empty String.
      #
      # val - The String value to parse.
      #
      # Returns an [Object] parsed from the string-based YAML value or empty [String] if the specified value is empty.
      def parse_yaml_value val
        if val.empty?
          ''
        else
          begin
            ::YAML.load %(--- #{val})
          rescue ::StandardError, ::SyntaxError => e
            val = val.gsub '\'', '\'\'' if val.include? '\''
            ::YAML.load %(--- \'#{val}\')
          end
        end
      end
    end
  end
end
