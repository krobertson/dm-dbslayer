require File.join(File.dirname(__FILE__), '/spec_helper')

describe DataObjects::Dbslayer::Command do
  before :all do
    @non_query    = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'non_reader_result.txt')).read
    @reader_query = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'reader_result.txt')).read
    @connection   = DataObjects::Dbslayer::Connection.new('dbslayer://localhost')
  end
  
  it 'should return a proper command type' do
    command = @connection.create_command 'FAKE QUERY'
    command.class.should == DataObjects::Dbslayer::Command
  end

  it 'should return proper result on a non-reader query' do
    response = Net::HTTPOK.new('get', 200, 'found')
    response.expects(:body).returns(@non_query)
    Net::HTTP.expects(:get_response).returns(response)

    command = @connection.create_command('FAKE QUERY')
    result = command.execute_non_query
    result.affected_rows.should == 5
  end

  it 'should return a reader when executing a query' do
    response = Net::HTTPOK.new('get', 200, 'found')
    response.expects(:body).returns(@reader_query)
    Net::HTTP.expects(:get_response).returns(response)

    command = @connection.create_command('FAKE QUERY')
    result = command.execute_reader
    result.class.should == DataObjects::Dbslayer::Reader
  end
  
  it 'should escape strings properly' do
    command = @connection.create_command('FAKE QUERY ?')
    query = command.escape_sql(['blah'])
    query.should == "FAKE QUERY 'blah'"
  end

  it 'should escape dates properly' do
    date = Date.parse('Sun May 18 16:22:47 -0700 2008')
    command = @connection.create_command('FAKE QUERY ?')
    query = command.escape_sql([date])
    query.should == "FAKE QUERY '2008-05-18'"
  end

  it 'should escape times properly' do
    time = Time.parse('Sun May 18 16:22:47 -0700 2008')
    command = @connection.create_command('FAKE QUERY ?')
    query = command.escape_sql([time])
    query.should == "FAKE QUERY '2008-05-18 16:22:47'"
  end

  it 'should escape DateTimes properly' do
    datetime = DateTime.parse('Sun May 18 16:22:47 -0700 2008')
    command = @connection.create_command('FAKE QUERY ?')
    query = command.escape_sql([datetime])
    query.should == "FAKE QUERY '2008-05-18 16:22:47'"
  end

  it 'should return an escaped query URL' do
    command = @connection.create_command('FAKE QUERY ?')
    query = command.query_url(['blah'])
    query.to_s.should == "http://localhost:9090/db?%7B%22SQL%22:%22FAKE%20QUERY%20'blah'%22%7D"
  end

  it 'should convert class column types to strings' do
    command = @connection.create_command('FAKE QUERY ?')
    types = command.set_types([Fixnum, Integer, String, Date])
    types.should == ['Fixnum', 'Integer', 'String', 'Date']
  end
end