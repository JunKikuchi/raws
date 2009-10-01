class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'

  class << self
    def create_bucket(bucket_name)
    end

    def delete_bucket(bucket_name)
    end

    def list
      Adapter.get_service
    end

    def each(&block)
    end

    def [](bucket_name)
    end
  end
end
