Feature: Blog Integration
  In order to test blog articles written in AsciiDoc

  Scenario: A blog article is generated from an AsciiDoc document
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/welcome.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
        <head>
          <title>Welcome</title>
        </head>
        <body>
          <article>
            <header>
              <span>by Blog Author</span>
              <time datetime="2017-09-01T15:00:00Z">Sep 1, 2017</time>
            </header>
            <h1>Welcome</h1>
      <div class="paragraph">
      <p>Welcome to my blog.</p>
      </div>
          </article>
        </body>
      </html>
      """

  Scenario: A blog article should accommodate multiple authors
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/joint-effort.html"
    Then I should see "John Smith, Jane Doe, Doc Writer"

  Scenario: A blog article marked as not published should be published when running the local server
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/not-published.html"
    Then I should see:
      """
      This article should only be published when running the local server.
      """

  Scenario: A blog article marked as not published should not be listed if filtered out
    Given a fixture app "asciidoc-blog-app"
    And app "asciidoc-blog-app" is using config "published-only"
    And the Server is running
    When I go to "/index.html"
    Then I should not see "/blog/not-published.html"

  Scenario: A blog article marked as not published should not be published when generating the site
    Given a fixture app "asciidoc-blog-app"
    And I run `middleman build`
    And was successfully built
    When I cd to "build"
    Then the following files should not exist:
    | blog/not-published.html |

  Scenario: A blog article marked as ignored should not be published
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/ignored.html"
    Then I should see "Not Found"

  Scenario: Specifying _auto_layout in blog configuration falls back to layout defined in AsciiDoc configuration
    Given a fixture app "asciidoc-blog-app"
    And app "asciidoc-blog-app" is using config "auto-layout"
    And the Server is running
    When I go to "/blog/welcome.html"
    Then I should see:
      """
      <title>AsciiDoc Page: Welcome</title>
      """

  Scenario: The layout defined in blog configuration takes precedence over the layout defined in AsciiDoc configuration
    Given a fixture app "asciidoc-blog-app"
    And app "asciidoc-blog-app" is using config "asciidoc-layout"
    And the Server is running
    When I go to "/blog/welcome.html"
    Then I should see:
      """
      <article>
      """

  Scenario: Specifying a layout for an article overrides layout defined in blog configuration
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/custom-layout.html"
    Then I should see:
      """
      <title>AsciiDoc Page: Custom Layout</title>
      """

  Scenario: Tags can be specified for an article in the AsciiDoc header as comma-separated list
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/tags-tags-tags.html"
    Then I should see:
      """
              <span class="tags">
                <span class="tag">fee</span>
                <span class="tag">fi</span>
                <span class="tag">fo</span>
                <span class="tag">fum</span>
              </span>
      """

  Scenario: Tags can be specified for an article in the AsciiDoc header as an array
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/more-tags.html"
    Then I should see:
      """
              <span class="tags">
                <span class="tag">bar</span>
                <span class="tag">baz</span>
                <span class="tag">foo</span>
              </span>
      """

  Scenario: A custom slug can be specified for an article in the AsciiDoc header
    Given the Server is running at "asciidoc-blog-app"
    When I go to "/blog/heisenberg.html"
    Then I should see:
      """
      <h1>Say My Name</h1>
      """

  Scenario: The date specified in the article overrides the date in the filename
    Given a fixture app "asciidoc-blog-app"
    And app "asciidoc-blog-app" is using config "date-in-filename"
    And the Server is running
    When I go to "/blog-2/2017/a-fresh-start.html"
    Then I should see:
      """
      <time datetime="2017-09-01T15:45:00Z">Sep 1, 2017</time>
      """

  Scenario: The date can be specified by the filename only
    Given a fixture app "asciidoc-blog-app"
    And app "asciidoc-blog-app" is using config "date-in-filename"
    And a file named "source/blog-2/2018-01-01-dates-are-arbitrary.adoc" with:
      """
      = What's in a Date?
      Reflective Soul
      
      Why do we put so much weight on a date?
      """
    And the Server is running
    When I go to "/blog-2/2018/dates-are-arbitrary.html"
    Then I should see:
      """
      <time datetime="2018-01-01T00:00:00Z">Jan 1, 2018</time>
      """

  Scenario: Disagreement between date in article and date in filename
    Given a fixture app "asciidoc-blog-app"
    And app "asciidoc-blog-app" is using config "date-in-filename"
    And a file named "source/blog-2/2017-04-20-what-day-is-it.adoc" with:
      """
      = What Day Is It?
      Joe Cool
      :revdate: 2017-10-20 09:45 MDT
      
      This blog is bakin'.
      """
    When I run `middleman build`
    Then the output should contain "doesn't match the date in its frontmatter"
    And the exit status should be 1
