#gem 'do_mysql', '=0.9.0'
require 'do_dbslayer'

module DataMapper
  module Adapters
    class DbslayerAdapter < MysqlAdapter
    end
  end
end
