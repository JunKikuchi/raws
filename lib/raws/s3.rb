class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'
  autoload :Object, 'raws/s3/object'

  class << self
    include Enumerable

    def create_bucket(bucket_name, location=nil)
      Adapter.put_bucket(bucket_name, location)
    end

    def delete_bucket(bucket_name, param=nil)
      filter(bucket_name).each do |object|
        delete(bucket_name, object['Key'])
      end if param == :force

      Adapter.delete_bucket(bucket_name)
    end

    def location(bucket_name)
      r = Adapter.get_bucket_location(bucket_name)
      l = r.doc['LocationConstraint']
      l.empty? ? 'US' : l
    end

    def owner
      @owner ||= Adapter.get_service.doc['ListAllMyBucketsResult']['Owner']
    end

    def list
      begin
        r = Adapter.get_service.doc['ListAllMyBucketsResult']
        @owner ||= r['Owner']
        r['Buckets']['Bucket'] || []
      end.map do |val|
        self.new(val['Name'], val['CreationDate'])
      end
    end
    alias :buckets :list

    def each(&block)
      list.each(&block)
    end

    def [](bucket_name)
      @cache ||= {}
      @cache[bucket_name] ||= self.new(bucket_name)
    end

    def filter(bucket_name, params={})
      begin
        r = Adapter.get_bucket(bucket_name, params)
        r.doc['ListBucketResult']['Contents'] || []
      end.map do |val|
        Object.new(self[bucket_name], val['Key'])
      end
    end
    alias :all :filter

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

=begin
    def acl(bucket_name, name=nil)
      get(
        bucket_name,
        name,
        :query  => {'acl' => nil},
        :parser => {:multiple => ['Grant']}
      ).doc
    end
=end
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

  def delete_bucket(param=nil)
    self.class.delete_bucket(@bucket_name, param)
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

  def copy(name, dest_bucket, dest_name=nil)
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

=begin
  def acl(name=nil)
    self.class.acl(@bucket_name, name)
  end
=end

  def <=>(a)
    bucket_name <=> a.bucket_name
  end
end
