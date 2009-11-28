require 'delegate'

class RAWS::S3::Header < SimpleDelegator
  attr_reader :bucket_name, :key

  def initialize(bucket_name, key, header=nil)
    @bucket_name, @key = bucket_name, key
    super(header ? header : RAWS::S3::Adapter.head_object(@bucket_name, @key).header)
  end

  def reload
    __setobj__(RAWS::S3::Adapter.head_object(@bucket_name, @key).header)
  end
end
