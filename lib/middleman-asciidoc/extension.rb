require 'asciidoctor' unless defined? Asciidoctor
require 'active_support/core_ext/time/zones' unless Time.respond_to? :zone

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

      option :attributes, [], 'Custom AsciiDoc attributes passed to all AsciiDoc-based pages. Defaults to empty Array. (Hash or Array)'
      option :backend, :html5, 'Moniker used to select output format for AsciiDoc-based pages. Defaults to :html5. (Symbol)'
      option :base_dir, :docdir, 'Base directory to use for the current AsciiDoc document. Defaults to :docdir, which is replaced with the document directory. (String)'
      option :safe, :safe, 'Safe mode level for AsciiDoc processor. Defaults to :safe. (Symbol)'
      option :layout, nil, 'Name of layout to use for AsciiDoc-based pages (not blog articles) (String or Symbol)'

      def initialize app, options_hash = {}, &block
        return if app.mode? :config
        super
        app.config.define_setting :asciidoc, {}, 'AsciiDoc processor options (Hash)'
        # NOTE support global :asciidoc_attributes setting for backwards compatibility
        app.config.define_setting :asciidoc_attributes, [], 'Custom AsciiDoc attributes (Hash or Array)'
      end

      # NOTE options passed to activate take precedence (e.g., activate :asciidoc, attributes: ['foo=bar'])
      def after_configuration
        app.config[:asciidoc_extensions] = prune_tilt_mapping!
        # Match behavior of middleman blog extension
        # Make sure ActiveSupport's TimeZone stuff has something to work with,
        # allowing people to set their desired time zone via Time.zone or
        # set :time_zone
        if app.config[:time_zone]
          ::Time.zone = app.config[:time_zone]
        else
          ::Time.zone ||= 'UTC'
        end
        zone_default = ::Time.find_zone! ::Time.zone
        raise 'Value assigned to time_zone not recognized.' unless zone_default
        ::Time.zone_default = zone_default

        if (app.config.setting :asciidoc).value_set?
          warn 'Using `set :asciidoc` to define options is deprecated. Please define options on `activate :asciidoc` instead.'
        end
        app.config[:asciidoc].tap do |cfg|
          attributes = {
            'site-root' => app.root.to_s,
            'site-source' => app.source_dir.to_s,
            'site-destination' => (dest = (app.root_path.join app.config[:build_dir]).to_s),
            'site-environment' => app.environment.to_s
          }.merge IMPLICIT_ATTRIBUTES
          if !!app.extensions[:directory_indexes]
            if app.config[:strip_index_file]
              attributes['relfilesuffix'] = app.config[:trailing_slash] ? '/' : ''
            else
              attributes['relfilesuffix'] = %(/#{app.config[:index_file]})
            end
            attributes['relfileprefix'] = '../'
          end
          # NOTE handles deprecated `set :asciidoc, attributes: ...`
          attributes = merge_attributes cfg[:attributes], attributes if cfg.key? :attributes
          # NOTE handles `activate :asciidoc, attributes: ...`
          if (options.setting :attributes).value_set?
            attributes = merge_attributes options[:attributes], attributes
          # NOTE handles `set :asciidoc_attributes ...`
          elsif (app.config.setting :asciidoc_attributes).value_set?
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
          case (base_dir = options[:base_dir])
          when :source
            cfg[:base_dir] = ::File.expand_path app.source_dir
          when :docdir
            cfg[:base_dir] = :docdir
          else
            cfg[:base_dir] = ::File.expand_path base_dir if base_dir
          end
          cfg[:backend] = options[:backend] if (options.setting :backend).value_set?
          cfg[:backend] = (cfg[:backend] || :html5).to_sym
          cfg[:safe] = options[:safe] if (options.setting :safe).value_set?
          cfg[:safe] = (cfg[:safe] || :safe).to_sym
          if (default_layout = options[:layout] || app.config[:layout])
            # set priority to run after blog extension, which also sets a layout
            app.sitemap.register_resource_list_manipulator :asciidoc_default_layout, (DefaultLayoutConfigurator.new app, default_layout.to_sym), 60
          end
        end
      end

      def manipulate_resource_list resources
        header_asciidoc_opts = app.config[:asciidoc].merge parse_header_only: true
        header_asciidoc_attrs = (header_asciidoc_opts[:attributes] = header_asciidoc_opts[:attributes].merge 'skip-front-matter' => '')
        use_docdir_as_base_dir = header_asciidoc_opts[:base_dir] == :docdir

        resources.select {|res| !res.ignored? && (asciidoc_file? res) }.each do |resource|
          path = resource.source_file
          if (page_asciidoc_opts = resource.options.delete :renderer_options)
            (page_asciidoc_opts[:attributes] ||= {})['page-id'] = resource.page_id
          else
            page_asciidoc_opts = { attributes: { 'page-id' => resource.page_id } }
          end
          opts, page = { renderer_options: page_asciidoc_opts }, {}

          header_asciidoc_opts[:base_dir] = page_asciidoc_opts[:base_dir] = ::File.dirname path if use_docdir_as_base_dir
          header_asciidoc_attrs['page-layout'] = %(#{resource.options[:layout]}@)
          # read AsciiDoc header only to set page options and data
          # header values can be accessed via app.data.page.<name> in the layout
          doc = ::Asciidoctor.load_file path, header_asciidoc_opts

          if (doc.attr? 'page-ignored') && !(doc.attr? 'page-ignored', 'false')
            resource.ignore!
            next
          end

          # NOTE page layout value cascades from site config -> extension config -> front matter -> page-layout attribute
          if doc.attr? 'page-layout'
            if (layout = doc.attr 'page-layout').empty?
              opts[:layout] = :_auto_layout
              opts[:layout_engine] = doc.attr 'page-layout-engine' if doc.attr? 'page-layout-engine'
            else
              case (layout = layout.to_sym)
              when :~, :null
                opts[:layout] = false
              when :false
                opts[:layout] = false
                page_asciidoc_opts[:header_footer] = true
              else
                opts[:layout] = layout
                opts[:layout_engine] = doc.attr 'page-layout-engine' if doc.attr? 'page-layout-engine'
              end
            end
          else
            opts[:layout] = false
            page_asciidoc_opts[:header_footer] = true
          end

          page[:title] = doc.doctitle if doc.header?
          if doc.attr? 'author'
            page[:author] = (author = doc.attr 'author')
            if (num_authors = (doc.attr 'authorcount').to_i) > 1
              page[:authors] = num_authors.times.map {|idx| doc.attr %(author_#{idx + 1}) }.compact
            else
              page[:authors] = [author]
            end
          end
          ['email', 'keywords', 'description'].each do |key|
            page[key.to_sym] = doc.attr key if doc.attr? key
          end
          if !(page.key? :date) && (doc.attr? 'revdate')
            begin
              page[:date] = ::Time.zone.parse (doc.attr 'revdate')
              # ...or hack to use app time zone, but only if time zone is not specified
              #page[:date] = ::DateTime.parse(%(#{doc.attr 'revdate'} #{::Time.zone.formatted_offset})).to_time
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

          # NOTE only options[:renderer_options] overrides keys defined in global options
          resource.add_metadata options: opts, page: page
        end
        resources
      end

      def asciidoc_file? resource
        (path = resource.source_file) && (path.end_with? *app.config[:asciidoc_extensions])
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
          (attribute_name.slice 5, attribute_name.length).to_sym
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
          val
        else
          begin
            ::YAML.load %(--- #{val})
          rescue ::StandardError, ::SyntaxError
            val = val.gsub '\'', '\'\'' if val.include? '\''
            ::YAML.load %(--- \'#{val}\')
          end
        end
      end

      # Resolves lazy AsciidoctorTemplate entries in the Tilt mapping, prunes those entries, and returns the
      # extensions (with the leading dot) for which the AsciidoctorTemplate is registered.
      #
      # Pruning prevents Tilt::Mapping.default_mapping#extensions_for from returning duplicate extensions.
      #
      # Returns a String Array of extensions for which the AsciidoctorTemplate is registered.
      def prune_tilt_mapping!
        if ::Tilt.respond_to? :default_mapping
          (mapping = ::Tilt.default_mapping).extensions_for(::Tilt::AsciidoctorTemplate).uniq.map do |ext|
            if mapping.lazy_map.key? ext
              mapping[ext]
              mapping.lazy_map.delete ext
            end
            %(.#{ext})
          end
        else
          ::Tilt.mappings.select {|_, classes| classes.include? ::Tilt::AsciidoctorTemplate }.keys.map {|ext| %(.#{ext}) }
        end
      end
    end

    # Resolves the automatic layout if no layout has been specified and this resource is not a blog article
    class DefaultLayoutConfigurator
      def initialize app, layout
        @app = app
        @layout = layout
      end

      def manipulate_resource_list resources
        resources.select {|res| !res.ignored? && (has_auto_layout? res) && (asciidoc_file? res) }.each do |resource|
          if (blog_article? resource) &&
              (blog_layout = resource.blog_data.options[:layout]) &&
              (blog_layout = blog_layout.to_sym) != :_auto_layout
            resource.options[:layout] = blog_layout
          else
            resource.options[:layout] = @layout
          end
        end
        resources
      end

      def has_auto_layout? resource
        resource.options[:layout] == :_auto_layout
      end

      def asciidoc_file? resource
        (path = resource.source_file) && (path.end_with? *@app.config[:asciidoc_extensions])
      end

      def blog_article? resource
        resource.respond_to? :blog_data
      end
    end
  end
end
