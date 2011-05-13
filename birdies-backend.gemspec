lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'birdies-backend/version'


Gem::Specification.new do |s|
  s.name     = "birdies-backend"
  s.version  = BirdiesBackend::VERSION
  s.platform = 'java'
  s.required_ruby_version = ">= 1.8.7"

  s.authors  = "Andreas Ronge"
  s.email    = 'andreas.ronge@gmail.com'
  s.homepage = "http://github.com/andreasronge/birdies-backend/tree"
  s.rubyforge_project = 'neo4j'
  s.summary = "Example app for Birdies Backend"
  s.description = <<-EOF
  Bla bla
  EOF

  s.require_path = 'lib'
  s.files = Dir.glob("{lib}/**/*") + %w(Gemfile birdies-backend.gemspec)
  s.add_dependency('json')
  s.add_dependency('twitter')
  s.add_dependency("neo4j", ">= 1.1.0")
end
