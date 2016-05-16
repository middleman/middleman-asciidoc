begin
  require 'bundler/gem_tasks'
rescue LoadError => e
  warn.message
end

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  exempt_tags = ''
  exempt_tags << '--tags ~@nojava ' if RUBY_PLATFORM == 'java'
  t.cucumber_opts = %(--color --tags ~@wip #{exempt_tags} --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'})
end

require 'rake/clean'

task :test => ['cucumber']
task :default => ['test', 'build']

begin
  require 'cane/rake_task'

  desc 'Run cane to check quality metrics'
  Cane::RakeTask.new(:quality) do |cane|
    cane.no_style = true
    cane.no_doc = true
    cane.abc_glob = 'lib/middleman-asciidoc/**/*.rb'
  end
rescue LoadError
  # warn 'cane not available, quality task not provided.'
end

desc 'Build HTML documentation'
task :doc do
  sh 'bundle exec yard'
end
