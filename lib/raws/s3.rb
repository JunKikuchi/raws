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

    def list
      Adapter.get_service['ListAllMyBucketsResult']['Buckets']['Bucket'] || []
    end

    def each(&block)
      list.each(&block)
    end

    def [](bucket_name)
    end
  end
end
