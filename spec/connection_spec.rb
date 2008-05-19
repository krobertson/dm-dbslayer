require File.join(File.dirname(__FILE__), '/spec_helper')

describe DataObjects::Dbslayer::Connection do
  it 'should contain a matching URI' do
    connection = DataObjects::Dbslayer::Connection.new('dbslayer://localhost')
    connection.uri.should === 'dbslayer://localhost'
  end

  it 'should generate the proper URL for the host' do
    connection = DataObjects::Dbslayer::Connection.new('dbslayer://localhost')
    connection.db_url.should == 'http://localhost:9090/db'
  end

  it 'should generate a URL with a port' do
    connection = DataObjects::Dbslayer::Connection.new('dbslayer://localhost:1234')
    connection.db_url.should == 'http://localhost:1234/db'
  end
end