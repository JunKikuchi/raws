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
      location = Adapter.get_bucket_location(bucket_name)['LocationConstraint']
      location.empty? ? 'US' : location
    end

    def list
      Adapter.get_service['ListAllMyBucketsResult']['Buckets']['Bucket'] || []
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
      )['ListBucketResult']['Contents'] || []
    end

    def put(bucket_name, name, object, header={})
      Adapter.put_object(bucket_name, name, object, header)
    end

    def copy(src_bucket, src_name, dest_bucket, dest_name)
      Adapter.copy_object(src_bucket, src_name, dest_bucket, dest_name)
    end

    def get(bucket_name, name)
      Adapter.get_object(bucket_name, name)
    end

    def head(bucket_name, name)
      Adapter.head_object(bucket_name, name)
    end

    def delete(bucket_name, name)
      Adapter.delete_object(bucket_name, name)
    end

    def acl(bucket_name, name=nil)
      Adapter.get_acl(bucket_name, name)
    end
  end

  attr_reader :bucket_name

  def initialize(bucket_name)
    @bucket_name = bucket_name
  end
end
