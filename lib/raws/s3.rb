class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'

  class << self
    def list
      Adapter.get_service
    end
  end
end
