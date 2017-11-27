source 'https://rubygems.org'

# Runtime dependencies are defined in middleman-asciidoc.gemspec
gemspec

if RUBY_ENGINE == 'jruby'
  git 'https://github.com/mojavelinux/middleman.git', branch: 'no-fast-blank' do
    gem 'middleman-core'
  end
end

# Build and doc tools
gem 'rake', '~> 10.3', require: false
gem 'yard', '~> 0.8', require: false

# Test tools
gem 'cucumber', '~> 2.0', require: false
gem 'aruba', '~> 0.7.4', require: false
gem 'capybara', '~> 2.5.0', require: false

# Code quality tools
gem 'cane', platforms: :mri, require: false

# Additional libraries for testing
# Middleman itself (use for testing against development version)
#gem 'middleman-core', :github => 'middleman/middleman', :branch => 'master'
gem 'middleman-blog', '~> 4.0', require: false
# NOTE middleman-cli required by middleman-blog
gem 'middleman-cli', '~> 4.0', require: false
gem 'listen', '~> 3.0.0', require: false # see https://github.com/middleman/middleman/pull/1891
