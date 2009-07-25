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

describe JAWS::SDB do
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
    sdb = JAWS::SDB
    %w'
      create_domain
      delete_domain
      metadata
      select
      get
      put
      batch_put
    '.each do |val|
      sdb.should respond_to val.to_sym
    end
  end

  before :all do
    @sdb = JAWS::SDB[JAWS_SDB_DOMAIN]
    #@sdb.create_domain
    #sleep 60
=begin
    @sdb.select.each do |val|
      @sdb.delete(val.first)
    end

    @sdb.put('100', 'a' => 10)
    @sdb.put('200', 'a' => [10, 20], 'b' => 20)
    @sdb.put('300', 'a' => [10, 20, 30], 'b' => 20, 'c' => 30)

    @sdb.batch_put(
      '400' => {'a' => [10, 20, 30, 40]},
      '500' => {'a' => [10, 20, 30, 40, 50]},
      '600' => {'a' => [10, 20, 30, 40, 50, 60]}
    )
=end
  end

  after :all do
    #@sdb.delete_domain
  end

  before do
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
