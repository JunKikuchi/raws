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

  before do
    @sdb = JAWS::SDB[JAWS_SDB_DOMAIN]
    @sdb.create_domain
    sleep 60
  end

  after do
    @sdb.delete_domain
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

  it 'each' do
=begin
    p JAWS::SDB::Adapter.put_attributes('aaa', 'a', {'a' => [1, 2, 3]})
    JAWS::SDB['aaa'].select.each do |attr|
      p attr
    end

    p JAWS::SDB::Adapter.put_attributes('aaa', 'a', {'a' => [10, 20, 30]})
    JAWS::SDB['aaa'].select.each do |attr|
      p attr
    end

    p JAWS::SDB::Adapter.put_attributes('aaa', 'a', {'a' => [100, 200]}, ['a'])
    JAWS::SDB['aaa'].select.each do |attr|
      p attr
    end

    p JAWS::SDB::get('aaa', 'a')

    p JAWS::SDB::Adapter.delete_attributes('aaa', 'a')
    JAWS::SDB['aaa'].select.each do |attr|
      p attr
    end

    p JAWS::SDB::Adapter.batch_put_attributes(
      'aaa',
      {
        'a' => {'a' => [1, 2, 3], 'b' => 4},
        'b' => {'a' => [10, 20, 30], 'b' => 40},
        'c' => {'a' => [100, 200, 300], 'b' => 400}
      }
    )
    JAWS::SDB['aaa'].select.each do |attr|
      p attr
    end

    p JAWS::SDB::Adapter.batch_put_attributes(
      'aaa',
      {'a' => {'a' => [100], 'b' => 400} },
      {'a' => ['a', 'b']}
    )
    JAWS::SDB['aaa'].select.each do |attr|
      p attr
    end
=end
  end
end
