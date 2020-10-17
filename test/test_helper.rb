$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "delegated_type"

require "minitest/autorun"


Dir["test/models/*.rb"].each {|file| require file.delete_prefix("test/") }

DB_FILE = 'tmp/test_db'
FileUtils.mkdir_p File.dirname(DB_FILE)
FileUtils.rm_f DB_FILE

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE

load 'schema.rb'
