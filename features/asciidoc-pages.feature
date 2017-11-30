Feature: AsciiDoc Support
  In order to test AsciiDoc support

  Scenario: Rendering html
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/hello.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
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
    And app "asciidoc-pages-app" is using config "default-layout"
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
    And app "asciidoc-pages-app" is using config "default-layout"
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
    And app "asciidoc-pages-app" is using config "default-layout"
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
    And app "asciidoc-pages-app" is using config "default-layout"
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
      <pre>{"title"=>"Page Data", "v-chrarray"=>["a", "b", "c"], "v-dblquote"=>"\"", "v-empty"=>"", "v-false"=>false, "v-hash"=>{"a"=>"a", "b"=>"b", "c"=>"c"}, "v-null"=>nil, "v-num"=>1, "v-numarray"=>[1, 2, 3], "v-quote"=>"'", "v-true"=>true}</pre>
      """

  Scenario: Promoting standard AsciiDoc attributes to page data
    Given the Server is running at "asciidoc-pages-app"
    When I go to "/inspect-standard-page-data.html"
    Then I should see:
      """
      <p>Page Title</p>
      <p>Doc Writer</p>
      <p>Doc Writer | Junior Writer</p>
      <p>doc.writer@example.com</p>
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
      <p>Unresolved directive in &lt;stdin&gt; - include::_chapters/ch01.adoc[]</p>
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
      <p>Unresolved directive in &lt;stdin&gt; - include::_chapters/ch01.adoc[]</p>
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

  Scenario: Restoring imagesdir to default value
    Given a fixture app "asciidoc-pages-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir!)
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
