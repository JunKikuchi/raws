class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'

  class << self
    include Enumerable

    def create_bucket(bucket_name)
      Adapter.put_bucket(bucket_name)
    end

    def delete_bucket(bucket_name)
      Adapter.delete_bucket(bucket_name)
    end

    def location(bucket_name)
      Adapter.get_bucket_location(bucket_name)
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

    def put(bucket_name, object)
    end

    def copy(bucket_name)
    end

    def get(bucket_name)
    end

    def head(bucket_name)
    end

    def delete(bucket_name)
    end
  end

  attr_reader :bucket_name

  def initialize(bucket_name)
    @bucket_name = bucket_name
  end
end
