SimpleCov.start do
  coverage_dir ENV['COVERAGE_REPORTS'] || 'tmp/coverage'
  add_filter '/features/'
  add_filter '/.bundle/'
  #formatter SimpleCov::Formatter::MultiFormatter[SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::CSVFormatter]
end
