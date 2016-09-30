require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :test do
  task :prepare do
    Kernel.system('./test_prepare.sh')
  end
end
