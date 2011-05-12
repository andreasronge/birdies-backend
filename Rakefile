$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'

require "birdies-backend/version"


desc "create the gemspec"
task :build do
  system "gem build birdies-backend.gemspec"
end

desc "release gem to gemcutter"
task :release => [:check_commited, :build] do
  system "gem push birdies-backend-#{BirdiesBackend::VERSION}-java.gem"
end

