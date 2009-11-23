class RAWS::S3
  autoload :Metadata, 'raws/s3/metadata'
  autoload :Adapter, 'raws/s3/adapter'
  autoload :Model, 'raws/s3/model'

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

    def filter(bucket_name, params={})
      begin
        response = Adapter.get_bucket(bucket_name, params)
        response.doc['ListBucketResult']['Contents'] || []
      end.map do |val|
        val
      end
    end
    alias :all :filter

    def put(bucket_name, name, header={}, &block)
      Adapter.put_object(bucket_name, name, header, &block)
    end

    def copy(src_bucket, src_name, dest_bucket, dest_name, header={})
      Adapter.copy_object(src_bucket, src_name, dest_bucket, dest_name, header)
    end

    def get(bucket_name, name, header={}, &block)
      Adapter.get_object(bucket_name, name, header, &block)
    end

    def head(bucket_name, name)
      Adapter.head_object(bucket_name, name)
    end

    def delete(bucket_name, name)
      Adapter.delete_object(bucket_name, name)
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

  def filter(params={})
    self.class.filter(@bucket_name, params)
  end
  alias :all :filter

  def put(name, header={}, &block)
    self.class.put(@bucket_name, name, header, &block)
  end

  def copy(name, dest_bucket, dest_name)
    self.class.copy(@bucket_name, name, dest_bucket, dest_name)
  end

  def get(name, header={}, &block)
    self.class.get(@bucket_name, name, header, &block)
  end

  def head(name)
    self.class.head(@bucket_name, name)
  end

  def delete(name)
    self.class.delete(@bucket_name, name)
  end

  def <=>(a)
    bucket_name <=> a.bucket_name
  end
end
