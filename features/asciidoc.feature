Feature: AsciiDoc Support
  In order to test included AsciiDoc support

  Scenario: Rendering html
    Given the Server is running at "asciidoc-app"
    When I go to "/hello.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      """

  Scenario: Rendering html with double file extension
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-extension.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      """

  Scenario: Rendering html with default layout
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      set :layout, :default
      """
    Given the Server is running at "asciidoc-app"
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

  Scenario: Rendering html with explicit layout
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-layout.html"
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

  Scenario: Rendering html with no layout
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-no-layout.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      """

  Scenario: Rendering html using title and tags from document
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-title.html"
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
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      set :layout, :default
      """
    Given the Server is running at "asciidoc-app"
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
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, safe: :unsafe
      set :layout, :default
      """
    Given the Server is running at "asciidoc-app"
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

  Scenario: Rendering html with title and layout from front matter
    Given the Server is running at "asciidoc-app"
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
    Given the Server is running at "asciidoc-app"
    When I go to "/ignored.html"
    Then I should see:
      """
      <h1>File Not Found</h1>
      """

  Scenario: Publishing site information as AsciiDoc attributes
    Given the Server is running at "asciidoc-app"
    When I go to "/site-information.html"
    Then I should see content matching %r{<p>site-root=.+/tmp/aruba/asciidoc-app</p>}
    Then I should see content matching %r{<p>site-source=.+/tmp/aruba/asciidoc-app/source</p>}
    Then I should see content matching %r{<p>site-destination=.+/tmp/aruba/asciidoc-app/build</p>}
    Then I should see content matching %r{<p>site-environment=development</p>}

  Scenario: Merging page data in front matter and AsciiDoc header
    Given the Server is running at "asciidoc-app"
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

  Scenario: Promoting standard AsciiDoc attributes to page data
    Given the Server is running at "asciidoc-app"
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
    Given the Server is running at "asciidoc-app"
    When I go to "/page-with-date-at-zone.html"
    Then I should see:
      """
      <html data-date="2017-01-01T16:00:00Z">
      """

  Scenario: Add application time zone to revdate when none specified
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      set :time_zone, 'MST'
      activate :asciidoc
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/page-with-date.html"
    Then I should see:
      """
      <html data-date="2017-01-01T16:00:00Z">
      """

  Scenario: Including a file relative to source root
    Given the Server is running at "asciidoc-app"
    When I go to "/master.html"
    Then I should see:
      """
      <div class="literalblock">
      <div class="content">
      <pre>I'm included content.</pre>
      </div>
      """

  Scenario: Including a file relative to document in subdirectory
    Given the Server is running at "asciidoc-app"
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
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, base_dir: :source
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/manual/index.html"
    Then I should see:
      """
      <p>Unresolved directive in &lt;stdin&gt; - include::_chapters/ch01.adoc[]</p>
      """

  Scenario: Including a file relative to document in subdirectory when base_dir is set to app.source_dir
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, base_dir: app.source_dir
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/manual/index.html"
    Then I should see:
      """
      <p>Unresolved directive in &lt;stdin&gt; - include::_chapters/ch01.adoc[]</p>
      """

  Scenario: Linking to a sibling page with directory indexes activated
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      activate :directory_indexes
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/link-to-page/"
    Then I should see:
      """
      <p>See <a href="../code/">code</a> run.</p>
      """

  Scenario: Linking to a sibling page with directory indexes activated and trailing slash disabled
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      activate :directory_indexes
      set :trailing_slash, false
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/link-to-page/"
    Then I should see:
      """
      <p>See <a href="../code">code</a> run.</p>
      """

  Scenario: Linking to a sibling page with directory indexes activated and strip index file disabled
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc
      activate :directory_indexes
      set :strip_index_file, false
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/link-to-page/"
    Then I should see:
      """
      <p>See <a href="../code/index.html">code</a> run.</p>
      """

  Scenario: Linking to an image
    Given the Server is running at "asciidoc-app"
    When I go to "/gallery.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="/images/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Linking to an image with a custom imagesdir
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="img/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Restoring imagesdir to value defined in page
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir=@)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="img/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Restoring imagesdir to default value
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir!)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Overriding imagesdir attribute in page with imagesdir configuration
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(imagesdir=/img)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-imagesdir.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="/img/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Configuring custom AsciiDoc attributes as Array
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(bar=bar@ foo={bar}{baz})
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-attribute.html"
    Then I should see "bar{baz}"

  Scenario: Configuring custom AsciiDoc attributes as Hash
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: { 'bar' => 'bar@', 'foo' => '{bar}{baz}' }
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-attribute.html"
    Then I should see "bar{baz}"

  Scenario: Highlighting source code
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(source-highlighter=html-pipeline)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/code.html"
    Then I should see:
      """
      <div class="listingblock">
      <div class="content">
      <pre lang="ruby"><code>puts "Is this mic on?"</code></pre>
      </div>
      </div>
      """
