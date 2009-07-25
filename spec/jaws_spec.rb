require 'rubygems'
require 'lib/jaws'
require 'spec/spec_config'

describe JAWS do
  it 'が持つ class methods' do
    %w'
      aws_access_key_id
      aws_secret_access_key
      escape
      sign
      fetch
    '.each do |val|
      JAWS.should respond_to val.to_sym
    end
  end
end
=begin
describe JAWS::SDB do
  before :all do
    @sdb = JAWS::SDB[JAWS_SDB_DOMAIN]
    #@sdb.create_domain
    #sleep 60

    #@sdb.select.each do |val|
    #  @sdb.delete(val.first)
    #end

    #@sdb.put('100', 'a' => 10)
    #@sdb.put('200', 'a' => [10, 20], 'b' => 20)
    #@sdb.put('300', 'a' => [10, 20, 30], 'b' => 20, 'c' => 30)

    #@sdb.batch_put(
    #  '400' => {'a' => [10, 20, 30, 40]},
    #  '500' => {'a' => [10, 20, 30, 40, 50]},
    #  '600' => {'a' => [10, 20, 30, 40, 50, 60]}
    #)
  end

  after :all do
    #@sdb.delete_domain
  end

  before do
  end

  it 'が持つ class methods' do
    %w'
      create_domain
      delete_domain
      metadata
      list
      select
      get
      put
      batch_put
      each
      []
    '.each do |val|
      JAWS::SDB.should respond_to val.to_sym
    end
  end

  it 'が持つ object methods' do
    %w'
      domain_name
      create_domain
      delete_domain
      metadata
      select
      get
      put
      batch_put
    '.each do |val|
      @sdb.should respond_to val.to_sym
    end
  end

  it 'metadata' do
    metadata = @sdb.metadata
    %w'
      AttributeValuesSizeBytes
      ItemNamesSizeBytes
      Timestamp
      AttributeValueCount
      ItemCount
      AttributeNamesSizeBytes
      AttributeNameCount
    '.each do |val|
      metadata.should have_key(val)
    end
  end

  it 'get' do
    @sdb.get('100').should == {'a' => '10'}
    @sdb.get('200').should == {'a' => ['10', '20'], 'b' => '20'}
    @sdb.get('400').should == {'a' => ['10', '20', '30', '40']}
  end

  it 'get("300", "b")' do
    @sdb.get('300', 'b').should == {'b' => '20'}
  end

  it 'put' do
    @sdb.put('100', {'a' => '101'})
    @sdb.get('100').should == {'a' => ['10', '101']}
    @sdb.put('100', {'a' => '10'}, 'a')
    5.times do
      p @sdb.get('100')
    end
    @sdb.get('100').should == {'a' => '10'}
  end

  it 'select' do
    keys = 6.times.map do |i|
      "#{i+1}00"
    end

    @sdb.select.each do |val|
      keys.should include(val.first)
    end
  end

  it 'select.where("a = ?", 10)' do
    @sdb.select.where('a = ?', 30).each do |val|
      %w'300 400 500 600'.should include(val.first)
    end
  end
end
=end
describe JAWS::SQS do
  it 'each' do
    begin
      JAWS::SQS.each do |val|
        p val.queue_url
        p val.get_attrs('VisibilityTimeout', 'Policy', 'LastModifiedTimestamp')
      end

      #p JAWS::SQS.get_attrs('aaa')
      #p JAWS::SQS.get_attrs('aaa', 'VisibilityTimeout')
      #p JAWS::SQS.set_attrs('aaa', 'VisibilityTimeout' => 60)
      #p JAWS::SQS.get_attrs('aaa', 'VisibilityTimeout')
    rescue => e
      p e.response.code
      p e.data
    end
  end
end
