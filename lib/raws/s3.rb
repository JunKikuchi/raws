class RAWS::S3
  autoload :Metadata, 'raws/s3/metadata'
  autoload :Adapter, 'raws/s3/adapter'
  autoload :Header, 'raws/s3/header'
  autoload :Model, 'raws/s3/model'
  autoload :ACL, 'raws/s3/acl'

  class << self
    include Enumerable

    attr_writer :http

    def http
      @http ||= RAWS.http
    end

    def create_bucket(bucket_name, location=nil, header={})
      Adapter.put_bucket(bucket_name, location, header)
    end

    def delete_bucket(bucket_name, force=nil)
      filter(bucket_name).each do |val|
        delete(bucket_name, val['Key'])
      end if force == :force

      Adapter.delete_bucket(bucket_name)
    end

    def owner
      Adapter.get_service.doc['ListAllMyBucketsResult']['Owner']
    end

    def list
      Adapter.get_service.doc['ListAllMyBucketsResult']
    end

    def buckets
      begin
        response = list
        @owner ||= response['Owner']
        response['Buckets']['Bucket'] || []
      end.map do |val|
        self[val['Name']]
      end
    end

    def each(&block)
      buckets.each(&block)
    end

    def [](bucket_name)
      @cache ||= {}
      @cache[bucket_name] ||= self.new(bucket_name)
    end

    def location(bucket_name)
      response = Adapter.get_bucket_location(bucket_name)
      location = response.doc['LocationConstraint']
      location.empty? ? 'US' : location
    end

    def acl(bucket_name, key=nil)
      ACL.new(bucket_name, key)
    end

    def filter(bucket_name, params={})
      begin
        response = Adapter.get_bucket(bucket_name, params)
        response.doc['ListBucketResult']['Contents'] || []
      end.map do |val|
        val
      end
    end
    alias :all :filter

    def put(bucket_name, key, header={}, &block)
      Adapter.put_object(bucket_name, key, header, &block)
    end

    def copy(src_bucket, src_key, dest_bucket, dest_key, header={})
      Adapter.copy_object(src_bucket, src_key, dest_bucket, dest_key, header)
    end

    def get(bucket_name, key, header={}, &block)
      Adapter.get_object(bucket_name, key, header, &block)
    end

    def head(bucket_name, key)
      Header.new(bucket_name, key)
    end

    def delete(bucket_name, key)
      Adapter.delete_object(bucket_name, key)
    end
  end

  attr_reader :bucket_name
  alias :name :bucket_name

  def initialize(bucket_name)
    @bucket_name = bucket_name
  end

  def create_bucket(location=nil)
    self.class.create_bucket(@bucket_name, location)
  end

  def delete_bucket(force=nil)
    self.class.delete_bucket(@bucket_name, force)
  end

  def location
    self.class.location(@bucket_name)
  end

  def acl(key=nil)
    self.class.acl(@bucket_name, key)
  end

  def filter(params={})
    self.class.filter(@bucket_name, params)
  end
  alias :all :filter

  def put(key, header={}, &block)
    self.class.put(@bucket_name, key, header, &block)
  end

  def copy(key, dest_bucket, dest_key)
    self.class.copy(@bucket_name, key, dest_bucket, dest_key)
  end

  def get(key, header={}, &block)
    self.class.get(@bucket_name, key, header, &block)
  end

  def head(key)
    self.class.head(@bucket_name, key)
  end

  def delete(key)
    self.class.delete(@bucket_name, key)
  end

  def <=>(a)
    bucket_name <=> a.bucket_name
  end
end
