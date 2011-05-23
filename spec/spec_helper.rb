require 'rubygems'
require "bundler/setup"
require 'rspec'
require 'fileutils'
require 'tmpdir'
require 'webmock/rspec'
require 'twitter'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

FIXTURE_DIR = File.join(File.dirname(__FILE__), 'fixtures')
require 'birdies-backend'


def rm_db_storage
  Neo4j.shutdown
  FileUtils.rm_rf Neo4j::Config[:storage_path]
  raise "Can't delete db" if File.exist?(Neo4j::Config[:storage_path])
end

def clean_db_storage
    Neo4j::Transaction.run do
      Neo4j._all_nodes.each { |n| n.del unless n.neo_id == 0 }
    end
end

RSpec.configure do |c|

#  c.after(:each) do
# clean_db_storage
#  end

#  c.before(:all) do
#    Neo4j.start
#  end
#
  c.after(:all) do
    rm_db_storage
  end
end
