require File.join(File.dirname(__FILE__), '/spec_helper')

describe DataObjects::Dbslayer::Reader do
  before :all do
    @reader_query = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'reader_result.txt')).read
    @reader = DataObjects::Dbslayer::Reader.new( JSON.parse(@reader_query)['RESULT'] )
  end

  it 'should return the fields' do
    @reader.fields.should == ["ID" , "Name" , "CountryCode" , "District" , "Population"]
  end

  it 'should return a row in the proper format' do
    @reader.next!
    @reader.values.should == [3793 , "New York" , "USA" , "New York" , 8008278]
  end

  it 'should read the property number of rows' do
    rows = 1
    while(@reader.next!)
      rows = rows + 1
    end
    rows.should == 10
  end
end