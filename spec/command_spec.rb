require File.join(File.dirname(__FILE__), '/spec_helper')

describe DataObjects::Dbslayer::Command do
  before :all do
    @non_query    = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'non_reader_result.txt')).read
    @reader_query = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'reader_result.txt')).read
    @connection   = DataObjects::Dbslayer::Connection.new('dbslayer://localhost')
  end
  
  before(:each) do
    @http_response = "HTTP/1.0 200 OK\r\n"
    @http_response << "Vary: Accept-Encoding\r\n"
    @http_response << "Content-Type: application/json\r\n"
    @http_response << "Accept-Ranges: bytes\r\n"
    @http_response << "Last-Modified: Thu, 30 Apr 2009 04:36:11 GMT\r\n"
    @http_response << "Connection: close\r\n"
    @http_response << "Date: Fri, 08 May 2009 06:21:36 GMT\r\n"
    @http_response << "Server: lighttpd/1.4.22\r\n"
  end
  
  it 'should return a proper command type' do
    command = @connection.create_command 'FAKE QUERY'
    command.class.should == DataObjects::Dbslayer::Command
  end

  it 'should return proper result on a non-reader query' do
    @http_response << "Content-Length: #{@non_query.size}\r\n"
    @http_response << "\r\n" # end of the headers
    @http_response << @non_query
    @http_response << "\r\n" # end of the response body
    non_query = StringIO.new(@http_response)
    TCPSocket.should_receive(:new).and_return(non_query)
    non_query.should_receive(:write)
    non_query.should_receive(:close)
    command = @connection.create_command('FAKE QUERY')
    result = command.execute_non_query
    result.affected_rows.should == 5
  end

  it 'should return a reader when executing a query' do
    @http_response << "Content-Length: #{@non_query.size}\r\n"
    @http_response << "\r\n" # end of the headers
    @http_response << @reader_query
    @http_response << "\r\n" # end of the response body
    reader_query = StringIO.new(@http_response)
    TCPSocket.should_receive(:new).and_return(reader_query)
    reader_query.should_receive(:write)
    reader_query.should_receive(:close)
    command = @connection.create_command('FAKE QUERY')
    result = command.execute_reader
    result.class.should == DataObjects::Dbslayer::Reader
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