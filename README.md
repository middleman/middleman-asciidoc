# Middleman AsciiDoc

`middleman-asciidoc` is an extension for the [Middleman] static site generator that adds support for AsciiDoc via [Asciidoctor](http://asciidoctor.org/)

[![Gem Version](https://badge.fury.io/rb/middleman-asciidoc.png)][gem]
[![Build Status](https://travis-ci.org/middleman/middleman-asciidoc.png)][travis]
[![Dependency Status](https://gemnasium.com/middleman/middleman-asciidoc.png?travis)][gemnasium]
[![Code Quality](https://codeclimate.com/github/middleman/middleman-asciidoc.png)][codeclimate]

## Installation

If you're just getting started, install the `middleman` gem and generate a new project:

```bash
gem install middleman
middleman init MY_PROJECT
```

If you already have a Middleman project: Add `gem "middleman-asciidoc"` to your `Gemfile` and run `bundle install`.

## Configuration

```ruby
activate :asciidoc
```

You can also pass options to AsciiDoc:

```ruby
activate :asciidoc, :asciidoc_attributes => %w(foo=bar)
```

The full set of options can be seen on your preview server's `/__middleman/config/` page.

## Community

The official community forum is available at: http://forum.middlemanapp.com

## Bug Reports

Github Issues are used for managing bug reports and feature requests. If you run into issues, please search the issues and submit new problems: https://github.com/middleman/middleman-asciidoc/issues

The best way to get quick responses to your issues and swift fixes to your bugs is to submit detailed bug reports, include test cases and respond to developer questions in a timely manner. Even better, if you know Ruby, you can submit [Pull Requests](https://help.github.com/articles/using-pull-requests) containing Cucumber Features which describe how your feature should work or exploit the bug you are submitting.

## How to Run Cucumber Tests

1. Checkout Repository: `git clone https://github.com/middleman/middleman-asciidoc.git`
2. Install Bundler: `gem install bundler`
3. Run `bundle install` inside the project root to install the gem dependencies.
4. Run test cases: `bundle exec rake test`

## License

Copyright (c) 2014 Dan Allen. MIT Licensed, see [LICENSE] for details.

[middleman]: http://middlemanapp.com
[gem]: https://rubygems.org/gems/middleman-asciidoc
[travis]: http://travis-ci.org/middleman/middleman-asciidoc
[gemnasium]: https://gemnasium.com/middleman/middleman-asciidoc
[codeclimate]: https://codeclimate.com/github/middleman/middleman-asciidoc
[LICENSE]: https://github.com/middleman/middleman-asciidoc/blob/master/LICENSE.md
