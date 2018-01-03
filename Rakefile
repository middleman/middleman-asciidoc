begin
  require 'bundler/gem_tasks'
rescue LoadError => e
  warn.message
end

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  exempt_tags = ''
  exempt_tags << ' --tags \'not @nojava\'' if RUBY_PLATFORM == 'java'
  t.cucumber_opts = %(--color --tags 'not @wip'#{exempt_tags} --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'})
end

require 'rake/clean'

task :test => ['cucumber']
task :default => ['test', 'build']

desc 'Build HTML documentation'
task :doc do
  sh 'bundle exec yard'
end
