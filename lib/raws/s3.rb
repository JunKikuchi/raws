class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'
  autoload :Object, 'raws/s3/object'

  class << self
    def create_bucket(bucket_name, location=nil, header={})
      Adapter.put_bucket(bucket_name, location, header)

      self[bucket_name]
    end

    def delete_bucket(bucket_name, force=nil)
      filter(bucket_name).each do |val|
        delete(bucket_name, val['Key'])
      end if force == :force

      Adapter.delete_bucket(bucket_name)

      nil
    end

    def owner
      @owner ||= Adapter.get_service.doc['ListAllMyBucketsResult']['Owner']
    end

    def buckets
      begin
        r = Adapter.get_service.doc['ListAllMyBucketsResult']
        @owner ||= r['Owner']
        r['Buckets']['Bucket'] || []
      end.map do |val|
        self[val['Name']]
      end
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
        r = Adapter.get_bucket(bucket_name, params)
        r.doc['ListBucketResult']['Contents'] || []
      end.map do |val|
        val
      end
    end
    alias :all :filter

    def put(bucket_name, name, object, header={})
      Adapter.put_object(bucket_name, name, object, header)
    end

    def copy(src_bucket, src_name, dest_bucket, dest_name, header={})
      Adapter.copy_object(src_bucket, src_name, dest_bucket, dest_name, header)
    end

    def get(bucket_name, name, params={})
      Adapter.get_object(bucket_name, name, params)
    end

    def head(bucket_name, name)
      Adapter.head_object(bucket_name, name)
    end

    def delete(bucket_name, name)
      Adapter.delete_object(bucket_name, name)
    end
  end

  attr_reader :bucket_name, :creation_date
  alias :name :bucket_name

  def initialize(bucket_name, creation_date=nil)
    @bucket_name = bucket_name
    @creation_date = Time.parse(creation_date) if creation_date
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

  def put(name, object, header={})
    self.class.put(@bucket_name, name, object, header)
  end

  def copy(name, dest_bucket, dest_name)
    self.class.copy(@bucket_name, name, dest_bucket, dest_name)
  end

  def get(name, params={})
    self.class.get(@bucket_name, name, params)
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
