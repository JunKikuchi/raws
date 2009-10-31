require 'spec/spec_config'

#RAWS.logger.level = Logger::DEBUG

describe RAWS::S3::Adapter do
  before :all do
=begin
    RAWS_S3_BUCKETS.each do |name, location|
      d RAWS::S3.create_bucket(name, location)
    end
    RAWS_S3_BUCKETS.each do |name, location|
      RAWS::S3.put(name, 'a', 'A')
      RAWS::S3.put(name, 'a/a', 'A-A')
      RAWS::S3.put(name, 'a/a/a', 'A-A-A')
      RAWS::S3.put(name, 'b', 'B')
      RAWS::S3.put(name, 'c', 'C')
    end
=end
  end

  after :all do
=begin
    RAWS_S3_BUCKETS.each do |name, location|
      RAWS::S3[name].delete_bucket
    end
=end
  end

  describe 'class' do
    it 'methods' do
      %w'
        create_bucket
        delete_bucket
        location
        list
        each
        []
        filter
        put
        copy
        get
        head
        delete
        acl
      '.each do |val|
        RAWS::S3.should respond_to val.to_sym
      end
    end

    it 'create_bucket' do
    end

    it 'delete_bucket' do
    end

    it 'location' do
      begin
        RAWS_S3_BUCKETS.each do |name, location|
          RAWS::S3.location(name).should == (location || 'US')
        end
      rescue => e
        d e.response.code
        d e.response.header
        d e.response.doc
      end
    end

    it 'list' do
      buckets = RAWS_S3_BUCKETS.map do |val|
        val.first
      end
      RAWS::S3.list.each do |val|
        buckets.should include(val['Name'])
      end
    end

    it 'each' do
      buckets = RAWS_S3_BUCKETS.map do |val|
        val.first
      end
      RAWS::S3.each do |val|
        buckets.should include(val['Name'])
      end
    end

    it '[]' do
      RAWS_S3_BUCKETS.each do |name, location|
        RAWS::S3[name].should be_kind_of(RAWS::S3)
        RAWS::S3[name].bucket_name.should == name
      end
    end

    it 'filter' do
      begin
        RAWS_S3_BUCKETS.each do |name, location|
          RAWS::S3.filter(name, 'prefix' => 'a/a/a')[0]['Key'].should == 'a/a/a'
        end
      rescue => e
        d e.response.code
        d e.response.header
        d e.response.doc
      end
    end

    it 'put' do
    end

    it 'copy' do
    end

    it 'get' do
    end

    it 'head' do
    end

    it 'delete' do
    end

    it 'acl' do
    end
  end

  describe 'object' do
    before do
      @s3 = RAWS::S3[RAWS_S3_BUCKETS[0]]
    end

    it 'method' do
      %w'
        create_bucket
        delete_bucket
        location
        filter
        <=>
      '.each do |val|
        @s3.should respond_to val.to_sym
      end
    end
  end
end
