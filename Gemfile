source 'https://rubygems.org'

# Runtime dependencies are defined in middleman-asciidoc.gemspec
gemspec

# NOTE when running tests on JRuby, use version of middleman-core that does not depend on fast_blank
#git 'https://github.com/middleman/middleman.git', ref: '1d13e415e27aa1b30d85fecebf8cc0f91d4023c6' do
# ...and which fixes the misplaced chmod command
git 'https://github.com/mojavelinux/middleman.git', branch: 'jruby-compat-fix' do
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
