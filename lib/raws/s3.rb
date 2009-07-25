class RAWS::S3
  autoload :Adapter, 'raws/s3/adapter'

  class << self
    def list
      Adapter.list_backets
    end
  end
end
