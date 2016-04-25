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

  Scenario: Rendering html using title from document
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-title.html"
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
  Scenario: Rendering html using title from document
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-title.html"
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

  Scenario: Including a file relative to document in subdirectory when base_dir is set
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, base_dir: app.source_dir.expand_path
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/manual/index.html"
    Then I should see:
      """
      <p>Unresolved directive in &lt;stdin&gt; - include::_chapters/ch01.adoc[]</p>
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

  Scenario: imagesdir configuratino should override imagesdir defined in page
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

  Scenario: Configuring custom AsciiDoc attributes
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      activate :asciidoc, attributes: %w(foo=bar)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-attribute.html"
    Then I should see "bar"

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
