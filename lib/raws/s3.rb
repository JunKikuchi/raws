class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'

  class << self
    include Enumerable

    def create_bucket(bucket_name, location=nil)
      Adapter.put_bucket(bucket_name, location)
    end

    def delete_bucket(bucket_name)
      Adapter.delete_bucket(bucket_name)
    end

    def location(bucket_name)
      response = Adapter.get_bucket_location(bucket_name)
      location = response.doc['LocationConstraint']
      location.empty? ? 'US' : location
    end

    def list
      begin
        response = Adapter.get_service
        response.doc['ListAllMyBucketsResult']['Buckets']['Bucket'] || []
      end.map do |val|
        self.new(val['Name'], val['CreationDate'])
      end
    end

    def each(&block)
      list.each(&block)
    end

    def [](bucket_name)
      @cache ||= {}
      @cache[bucket_name] ||= self.new(bucket_name)
    end

    def filter(bucket_name, params={})
      Adapter.get_bucket(
        bucket_name,
        params
      ).doc['ListBucketResult']['Contents'] || []
    end

    def put(bucket_name, name, object, header={})
      Adapter.put_object(bucket_name, name, object, header)
    end

    def copy(src_bucket, src_name, dest_bucket, dest_name=nil)
      Adapter.copy_object(
        src_bucket,
        src_name,
        dest_bucket,
        dest_name || src_name
      )
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

    def acl(bucket_name, name=nil)
      get(
        bucket_name,
        name,
        :query  => {'acl' => nil},
        :parser => {:multiple => ['Grant']}
      ).doc
    end
  end

  attr_reader :bucket_name, :creation_date

  def initialize(bucket_name, creation_date=nil)
    @bucket_name = bucket_name
    @creation_date = Time.parse(creation_date) if creation_date
  end

  def create_bucket(location=nil)
    self.class.create_bucket(@bucket_name, location)
  end

  def delete_bucket
    self.class.delete_bucket(@bucket_name)
  end

  def location
    self.class.location(@bucket_name)
  end

  def filter(params={})
    self.class.filter(@bucket_name, params)
  end

  def put(name, object, attrs={})
    self.class.put(@bucket_name, name, object, attrs)
  end

  def copy(name, dest_bucket, dest_name=nil)
    self.class.copy(@bucket_name, name, dest_bucket, dest_name)
  end

  def get(name)
    self.class.get(@bucket_name, name)
  end

  def delete(name)
    self.class.delete(@bucket_name, name)
  end

  def acl(name=nil)
    self.class.acl(@bucket_name, name)
  end

  def <=>(a)
    bucket_name <=> a.bucket_name
  end
end
