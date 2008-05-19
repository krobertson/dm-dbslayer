require 'rubygems'
gem 'rspec', '>=1.1.3'
require 'spec'
require 'pathname'
require 'data_mapper'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

DataMapper.setup(:default, 'mysql://localhost/test')
require 'dbslayer_adapter'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end