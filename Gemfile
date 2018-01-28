source 'https://rubygems.org'

# Runtime dependencies are defined in middleman-asciidoc.gemspec
gemspec

# NOTE to run tests on JRuby, use a version of middleman-core that:
# a) doesn't depend on fast_blank and
# b) fixes the misplaced chmod command
git 'https://github.com/middleman/middleman.git', ref: '0936519ab9fc28cf1c07dc8ed555d97d96c8c176' do
  gem 'middleman-core'
end if RUBY_ENGINE == 'jruby'

# Build and doc tools
gem 'rake', '~> 12.3.0', require: false

# Test tools
gem 'aruba', '~> 0.14.0', require: false
gem 'capybara', '~> 2.16.0', require: false
if (Gem::Version.new RUBY_VERSION) < (Gem::Version.new '2.2.0')
  gem 'cucumber', '~> 2.99.0', require: false
else
  gem 'cucumber', '~> 3.1.0', require: false
end

# Code coverage tools
gem 'simplecov', '~> 0.15.0', require: false

# Additional libraries for testing
# Middleman itself (use for testing against development version)
#gem 'middleman-core', :github => 'middleman/middleman', :branch => 'master'
gem 'middleman-blog', '~> 4.0.2', require: false
# NOTE middleman-cli required by middleman-blog
if (Gem::Version.new RUBY_VERSION) < (Gem::Version.new '2.2.0')
  gem 'middleman-cli', '~> 4.0.0', require: false
else
  gem 'middleman-cli', '~> 4.2.0', require: false
end
gem 'asciidoctor-diagram', require: false
