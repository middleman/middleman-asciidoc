PROJECT_ROOT_PATH = File.expand_path '../../..', __FILE__
# simplecov loads settings from .simplecov
require 'simplecov' if ENV['COVERAGE'] == 'true'
ENV['TEST'] = 'true'
require 'middleman-core'
require 'middleman-core/step_definitions'
require File.join PROJECT_ROOT_PATH, 'lib', 'middleman-asciidoc'
