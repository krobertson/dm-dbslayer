require File.join(File.dirname(__FILE__), '/spec_helper')

describe DataObjects::Dbslayer::Reader do
  before :all do
    @reader_query = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'reader_result.txt')).read
    @types_query  = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'types_test.txt')).read
    @reader       = DataObjects::Dbslayer::Reader.new( JSON.parse(@reader_query)['RESULT'] )

    @types_reader = DataObjects::Dbslayer::Reader.new( JSON.parse(@types_query)['RESULT'] )
    @types_reader.next!
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

  it 'should be able to read a number' do
    @types_reader.values[0].class.should == Fixnum
    @types_reader.values[0].should == 1
  end

  it 'should be able to read Date types' do
    @types_reader.values[1].class.should == Date
    @types_reader.values[1].should == Date.new(2008, 5, 19)
  end
  
  it 'should be able to read a Time(stamp) type' do
    @types_reader.values[2].class.should == Time
    @types_reader.values[2].should == Time.mktime(2008, 5, 19, 9, 46, 56)
  end

  it 'should be able to read a DateTime type' do
    @types_reader.values[3].class.should == DateTime
    @types_reader.values[3].should == DateTime.new(2008, 5, 19, 9, 48, 7)
  end
  
  it 'should be able to read a basic time type' do
    @types_reader.values[4].class.should == Time
    @types_reader.values[4].should == Time.parse('09:48:07')
  end

  it 'should be able to read a year type' do
    @types_reader.values[5].class.should == Fixnum
    @types_reader.values[5].should == 2008
  end

  it 'should be able to read a boolean type' do
    @types_reader.values[6].class.should == TrueClass
    @types_reader.values[6].should == true
  end
end