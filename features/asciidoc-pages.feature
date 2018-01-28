Feature: AsciiDoc Support
  In order to test AsciiDoc support

  Scenario: Rendering HTML page from AsciiDoc document
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/hello.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      """

  Scenario: Rendering HTML page from AsciiDoc document with alternate extension
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/goodbye.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>So long!</p>
      </div>
      """

  Scenario: Rendering html with double file extension
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/hello-with-extension.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      """

  Scenario: Rendering html with layout defined in extension config
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, layout: :default
      set :layout, :global
      """
    And the Server is running
    When I go to "/hello.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with no layout specified
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "global-layout"
    And a file named "source/no-layout.adoc" with:
      """
      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/no-layout.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with auto layout specified
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "global-layout"
    And a file named "source/auto-layout.adoc" with:
      """
      :page-layout: _auto_layout

      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/auto-layout.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with blank layout specified
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "global-layout"
    And a file named "source/blank-layout.adoc" with:
      """
      :page-layout:

      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/blank-layout.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with explicit layout specified
    Given a fixture app "asciidoc-pages-app"
    And a file named "source/explicit-layout.adoc" with:
      """
      :page-layout: default

      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/explicit-layout.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with layout unset
    Given a fixture app "asciidoc-pages-app"
    And a file named "source/unset-layout.adoc" with:
      """
      :!page-layout:

      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/unset-layout.html"
    Then I should see:
      """
      <meta name="generator" content="Asciidoctor
      """
    And I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      """

  Scenario: Rendering html with false layout specified
    Given a fixture app "asciidoc-pages-app"
    And a file named "source/false-layout.adoc" with:
      """
      :page-layout: false

      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/false-layout.html"
    Then I should see:
      """
      <meta name="generator" content="Asciidoctor
      """
    And I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      """

  Scenario: Rendering html with null layout specified
    Given a fixture app "asciidoc-pages-app"
    And a file named "source/null-layout.adoc" with:
      """
      :page-layout: null

      Hello, AsciiDoc!
      """
    And the Server is running at "asciidoc-pages-app"
    When I go to "/null-layout.html"
    Then I should not see:
      """
      <!DOCTYPE html>
      """
    And I should not see:
      """
      <meta name="generator" content="Asciidoctor
      """
    And I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      """

  Scenario: Rendering html with layout and layout engine specified
    Given a fixture app "asciidoc-pages-app"
    And a file named "source/layout-engine.adoc" with:
      """
      :page-layout: engine
      :page-layout-engine: str
      = Page Title

      Hello, AsciiDoc!
      """
    And the Server is running
    When I go to "/layout-engine.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>str :: Page Title</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html using title and tags from document
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/hello-with-title-and-tags.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Page Title</title>
      <meta name="tags" content="colophon,sample">
      </head>
      <body>
      <h1>Page Title</h1>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Default safe mode for AsciiDoc processor
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "global-layout"
    And the Server is running
    When I go to "/safe-mode.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Safe Mode</title>
      </head>
      <body>
      <div class="paragraph">
      <p>safe</p>
      </div>
      </body>
      </html>
      """

  Scenario: Setting safe mode on AsciiDoc processor
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, safe: :unsafe
      set :layout, :default
      """
    And the Server is running
    When I go to "/safe-mode.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Safe Mode</title>
      </head>
      <body>
      <div class="paragraph">
      <p>unsafe</p>
      </div>
      </body>
      </html>
      """

  Scenario: Setting backend on AsciiDoc processor
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, backend: 'xhtml'
      set :layout, :default
      """
    And the Server is running
    When I go to "/backend.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>xml</p>
      </div>
      <hr/>
      <div class="imageblock">
      <div class="content">
      <img src="/images/tiger.gif" alt="tiger"/>
      </div>
      </div>
      """

  Scenario: Rendering html with title and layout from front matter
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/hello-with-front-matter.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Page Title</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with layout from page directive
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "page-layout"
    And the Server is running
    When I go to "/hello.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      </body>
      </html>
      """

  Scenario: Ignoring files marked as ignored
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/ignored.html"
    Then I should see:
      """
      <h1>File Not Found</h1>
      """

  Scenario: Publishing site information as AsciiDoc attributes
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/site-information.html"
    Then I should see content matching %r{<p>site-root=.+/tmp/aruba/asciidoc-pages-app</p>}
    And I should see content matching %r{<p>site-source=.+/tmp/aruba/asciidoc-pages-app/source</p>}
    And I should see content matching %r{<p>site-destination=.+/tmp/aruba/asciidoc-pages-app/build</p>}
    And I should see content matching %r{<p>site-environment=development</p>}

  Scenario: Publishing document information as AsciiDoc attributes
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/document-information.html"
    Then I should see content matching %r{<p>docdir=.+/tmp/aruba/asciidoc-pages-app/source</p>}
    And I should see content matching %r{<p>docfile=.+/tmp/aruba/asciidoc-pages-app/source/document-information.adoc</p>}
    And I should see "<p>docfilesuffix=.adoc</p>"
    And I should see "<p>docname=document-information</p>"
    And I should see content matching %r{<p>outdir=.+/tmp/aruba/asciidoc-pages-app/build</p>}
    And I should see content matching %r{<p>outfile=.+/tmp/aruba/asciidoc-pages-app/build/document-information.html</p>}

  Scenario: Sets value of to_dir option on parsed document
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/page-data.html"
    Then I should see content matching %r{<p>to_dir=.+/tmp/aruba/asciidoc-pages-app/build</p>}

  Scenario: Assigning page ID to page-id attribute
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/topic/echo-page-id.html"
    Then I should see "topic/echo-page-id"

  Scenario: Merging page data in front matter and AsciiDoc header
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/hello-with-mixed-page-data.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Page Title</title>
      </head>
      <body>
      <h1>Page Title</h1>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Parses value of page attribute as YAML data
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/page-data.html"
    Then I should see:
      """
      <pre>{"document"=>"Page Data", "id"=>"page-data", "title"=>"Page Data", "v-chrarray"=>["a", "b", "c"], "v-dblquote"=>"\"", "v-empty"=>"", "v-false"=>false, "v-hash"=>{"a"=>"a", "b"=>"b", "c"=>"c"}, "v-null"=>nil, "v-num"=>1, "v-numarray"=>[1, 2, 3], "v-quote"=>"'", "v-true"=>true}</pre>
      """

  Scenario: Promoting standard AsciiDoc attributes to page data
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/inspect-standard-page-data.html"
    Then I should see:
      """
      <p>Page Title</p>
      <p>Doc Writer</p>
      <p>doc.writer@example.com</p>
      <p>Doc Writer | Junior Writer | Random Dude</p>
      <p>https://social.example.com/jrw</p>
      <p>jrw</p>
      <p>http://example.com</p>
      <p>This is a sample page.</p>
      <p>meta, AsciiDoc, Middleman</p>
      """

  Scenario: Honor time zone specified in revdate
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/page-with-date-at-zone.html"
    Then I should see:
      """
      <html data-date="2017-01-01T16:00:00Z">
      """

  Scenario: Add application time zone to revdate when none specified
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      set :time_zone, 'MST'
      activate :asciidoc
      """
    And the Server is running
    When I go to "/page-with-date.html"
    Then I should see:
      """
      <html data-date="2017-01-01T16:00:00Z">
      """

  Scenario: Using a fixed time as local time for pages
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      set :time_zone, 'America/Los_Angeles'
      set :time, (Time.parse '2017-01-01 09:00:00 MST')
      activate :asciidoc
      """
    And the Server is running
    When I go to "/localtime.html"
    Then I should see:
      """
      2017-01-01 08:00:00 PST
      """

  Scenario: Including a file relative to source root
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/master.html"
    Then I should see:
      """
      <div class="literalblock">
      <div class="content">
      <pre>I'm included content.</pre>
      </div>
      """

  Scenario: Including a file relative to document in subdirectory
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/manual/index.html"
    Then I should see:
      """
      <h1>Manual</h1>
      <div class="sect1">
      <h2 id="_chapter_01">Chapter 01</h2>
      <div class="sectionbody">
      <div class="paragraph">
      <p>content</p>
      </div>
      </div>
      </div>
      """

  Scenario: Including a file relative to document in subdirectory when base_dir is set to :source
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, base_dir: :source
      """
    And the Server is running
    When I go to "/manual/index.html"
    Then I should see:
      """
      <p>Unresolved directive in index.adoc - include::_chapters/ch01.adoc[]</p>
      """

  Scenario: Including a file relative to document in subdirectory when base_dir is set to app.source_dir
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, base_dir: app.source_dir
      """
    And the Server is running
    When I go to "/manual/index.html"
    Then I should see:
      """
      <p>Unresolved directive in index.adoc - include::_chapters/ch01.adoc[]</p>
      """

  Scenario: Linking to a sibling page with directory indexes activated
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      activate :directory_indexes
      """
    And the Server is running
    When I go to "/link-to-page/"
    Then I should see:
      """
      <p>See <a href="../code/">code</a> run.</p>
      """

  Scenario: Linking to a sibling page with directory indexes activated and trailing slash disabled
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      activate :directory_indexes
      set :trailing_slash, false
      """
    And the Server is running
    When I go to "/link-to-page/"
    Then I should see:
      """
      <p>See <a href="../code">code</a> run.</p>
      """

  Scenario: Linking to a sibling page with directory indexes activated and strip index file disabled
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      activate :directory_indexes
      set :strip_index_file, false
      """
    And the Server is running
    When I go to "/link-to-page/"
    Then I should see:
      """
      <p>See <a href="../code/index.html">code</a> run.</p>
      """

  Scenario: Linking to an image
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/gallery.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="/images/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Linking to an image with a custom imagesdir
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="img/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Restoring imagesdir to value defined in page
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir=@)
      """
    And the Server is running
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="img/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Setting imagesdir to blank
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir=)
      """
    And the Server is running
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Restoring imagesdir to default value
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(-imagesdir)
      """
    And a file named "source/imagesdir.adoc" with:
      """
      imagesdir={imagesdir}
      """
    And the Server is running
    When I go to "/imagesdir.html"
    Then I should see "imagesdir="

  Scenario: Overriding imagesdir attribute in page with imagesdir configuration
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir=/img)
      """
    And the Server is running
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="/img/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Forcefully unsetting AsciiDoc attributes in document
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(!icons sectanchors!)
      """
    And the Server is running
    When I go to "/page-with-attributes.html"
    Then I should see:
      """
      !icons
      !sectanchors
      """

  Scenario: Configuring custom AsciiDoc attributes as Array
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(bar=bar@ foo={bar}{baz})
      """
    And the Server is running
    When I go to "/custom-attribute.html"
    Then I should see "bar{baz}"

  Scenario: Configuring custom AsciiDoc attributes as Hash
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: { 'bar' => 'bar@', 'foo' => '{bar}{baz}' }
      """
    And the Server is running
    When I go to "/custom-attribute.html"
    Then I should see "bar{baz}"

  Scenario: Defaults attributes setting to empty Hash
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc do |asciidoc|
        if Hash === asciidoc.attributes
          asciidoc.attributes = asciidoc.attributes.merge({ 'foo' => 'bar' })
        end
      end
      """
    And the Server is running
    When I go to "/custom-attribute.html"
    Then I should see:
      """
      bar
      """

  Scenario: Using non-string attribute values in AsciiDoc attributes Hash
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: {
        'sectnumlevels' => 2,
        'sectids' => nil,
        'experimental' => true,
        'builddate' => (DateTime.parse '2017-01-01T09:00:00-05:00')
      }
      """
    And a file named "source/non-string-attrs.adoc" with:
      """
      {sectnumlevels}
      ifndef::sectids[!sectids]
      ifdef::experimental[experimental]
      {builddate}
      """
    And the Server is running
    When I go to "/non-string-attrs.html"
    Then I should see:
      """
      2
      !sectids
      experimental
      2017-01-01T09:00:00-05:00
      """

  Scenario: Passing invalid type to attributes setting
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: 'icons=font'
      """
    Then running the Server should raise an exception

  Scenario: Setting custom attributes for a specific page
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "page-attributes"
    And the Server is running
    When I go to "/with-sections.html"
    Then I should see:
      """
      <h2 id="_section_a"><a class="anchor" href="#_section_a"></a>Section A</h2>
      """

  Scenario: Setting custom attributes for a specific page abbrev
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "page-attributes-abbrev"
    And the Server is running
    When I go to "/with-sections.html"
    Then I should see:
      """
      <h2 id="_section_a"><a class="anchor" href="#_section_a"></a>Section A</h2>
      """

  Scenario: Using custom templates to convert AsciiDoc document nodes to HTML
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc do |asciidoc|
        asciidoc.template_dirs = 'source/_templates'
        asciidoc.template_engine = :erb
      end
      """
    And a file named "source/rosy-paragraph.adoc" with:
      """
      [.rosy]
      Rosey paragraph.
      """
    And the Server is running
    When I go to "/rosy-paragraph.html"
    Then I should see:
      """
      <p class="rosy">Rosey paragraph.</p>
      """

  Scenario: Warn when options are set using `set :asciidoc`
    Given a fixture app "asciidoc-pages-app"
    And app "asciidoc-pages-app" is using config "set-asciidoc"
    And I run `middleman build`
    And was successfully built
    Then the output should contain "Using `set :asciidoc` to set options for AsciiDoc is no longer supported."

  Scenario: Highlighting source code
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(source-highlighter=html-pipeline)
      """
    And the Server is running
    When I go to "/code.html"
    Then I should see:
      """
      <div class="listingblock">
      <div class="content">
      <pre lang="ruby"><code>puts "Is this mic on?"</code></pre>
      </div>
      </div>
      """

  Scenario: Asciidoctor Diagram integration
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      require 'asciidoctor-diagram'
      activate :asciidoc, safe: :unsafe
      """
    And a file named "source/diagrams/document.adoc" with:
      """
      [ditaa,document,png]
      ....
      +-----+
      |{d}  |
      |     |
      +-----+
      ....
      """
    And the Server is running
    When I go to "/diagrams/document.html"
    Then I should see:
      """
      <img src="/images/document.png" alt="document"
      """
    # NOTE we can't request the image URL since it's not in the sitemap
    When I cd to "build"
    Then the following files should exist:
    | images/document.png |

  Scenario: Asciidoctor Diagram cache
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      require 'asciidoctor-diagram'
      activate :asciidoc, safe: :unsafe
      """
    And a file named "source/diagrams/storage.adoc" with:
      """
      [ditaa,storage,png]
      ....
      +-----+
      |{s}  |
      |     |
      +-----+
      ....
      """
    And the Server is running
    When I go to "/diagrams/storage.html"
    Then the file ".asciidoctor/diagram/storage.png.cache" should contain "checksum"

  Scenario: Custom Asciidoctor Diagram imagesoutdir
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      require 'asciidoctor-diagram'
      activate :asciidoc, safe: :unsafe,
        attributes: { 'imagesoutdir' => (app.root_path.join app.config[:build_dir], 'images/diagrams').to_s }
      """
    And a file named "source/diagrams/io.adoc" with:
      """
      :imagesdir: {imagesdir}/diagrams
      [ditaa,io,png]
      ....
      +-----+
      |{io} |
      |     |
      +-----+
      ....
      """
    And the Server is running
    When I go to "/diagrams/io.html"
    Then I should see:
      """
      <img src="/images/diagrams/io.png" alt="io"
      """
    When I cd to "build"
    Then the following files should exist:
    | images/diagrams/io.png |
