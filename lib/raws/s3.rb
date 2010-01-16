class RAWS::S3
  autoload :Metadata, 'raws/s3/metadata'
  autoload :Adapter, 'raws/s3/adapter'
  autoload :Model, 'raws/s3/model'
  autoload :Owner, 'raws/s3/owner'
  autoload :ACL, 'raws/s3/acl'

  class << self
    include Enumerable

    attr_writer :http

    def http
      @http ||= RAWS.http
    end

    # Creates a new bucket and returns the instance of RAWS::S3.
    def create_bucket(bucket_name, location=nil, header={})
      Adapter.put_bucket bucket_name, location, header
      self[bucket_name]
    end

    # Delete the bucket.
    def delete_bucket(bucket_name, force=nil)
      filter(bucket_name).each do |val|
        delete(bucket_name, val['Key'])
      end if force == :force

      Adapter.delete_bucket(bucket_name)
    end

    # Returns the instance of RAWS::S3::Owner.
    def owner
      Owner.new Adapter.get_service.doc['ListAllMyBucketsResult']['Owner']
    end

    # Returns an array of RAWS::S3 objects.
    def list_buckets
      begin
        doc = Adapter.get_service.doc
        doc['ListAllMyBucketsResult']['Buckets']['Bucket'] || []
      end.map do |val|
        self[val['Name']]
      end
    end

    def buckets(&block)
      if block_given?
        each(&block)
      else
        map
      end
    end

    def each(&block)
      list_buckets.each(&block)
    end

    # Returns the instance of RAWS::S3.
    def [](bucket_name)
      self.new bucket_name
    end

    def location(bucket_name)
      doc = Adapter.get_bucket_location(bucket_name).doc
      doc['LocationConstraint'].empty? && 'US'
    end

    def acl(bucket_name, key=nil)
      ACL.new bucket_name, key
    end

    def filter(bucket_name, query={}, &block)
      begin
        ret = Adapter.get_bucket(bucket_name, query).doc['ListBucketResult']
        ret['Contents'].each do |contents|
          block.call contents
        end if ret.key? 'Contents'
        query['Marker'] = ret['Marker'].empty? ? nil : ret['Marker']
      end while query['Marker']
    end
    alias :all :filter

    def put_object(bucket_name, key, header={}, &block)
      Adapter.put_object bucket_name, key, header, &block
    end
    alias :put :put_object

    def copy_object(src_bucket, src_key, dest_bucket, dest_key, header={})
      Adapter.copy_object src_bucket, src_key, dest_bucket, dest_key, header
    end
    alias :copy :copy_object

    def get_object(bucket_name, key, header={}, &block)
      Adapter.get_object bucket_name, key, header, &block
    end
    alias :get :get_object

    def head_object(bucket_name, key)
      Adapter.head_object bucket_name, key
    end
    alias :head :head_object

    def delete_object(bucket_name, key)
      Adapter.delete_object bucket_name, key
    end
    alias :delete :delete_object
  end

  attr_reader :bucket_name
  alias :name :bucket_name

  def initialize(bucket_name)
    @bucket_name = bucket_name
  end

  def create_bucket(location=nil)
    self.class.create_bucket @bucket_name, location
  end

  def delete_bucket(force=nil)
    self.class.delete_bucket @bucket_name, force
  end

  def owner
    self.class.owner
  end

  def location
    self.class.location @bucket_name
  end

  def acl(key=nil)
    self.class.acl @bucket_name, key
  end

  def filter(query={}, &block)
    self.class.filter @bucket_name, query, &block
  end
  alias :all :filter

  def put_object(key, header={}, &block)
    self.class.put_object @bucket_name, key, header, &block
  end
  alias :put :put_object

  def copy_object(key, dest_bucket, dest_key)
    self.class.copy_object @bucket_name, key, dest_bucket, dest_key
  end
  alias :copy :copy_object

  def get_object(key, header={}, &block)
    self.class.get_object @bucket_name, key, header, &block
  end
  alias :get :get_object

  def head_object(key)
    self.class.head_object @bucket_name, key
  end
  alias :head :head_object

  def delete_object(key)
    self.class.delete_object @bucket_name, key
  end
  alias :delete :delete_object

  def <=>(a)
    bucket_name <=> a.bucket_name
  end
end
