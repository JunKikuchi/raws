module RAWS::S3::Model
  module ClassMethods
    attr_accessor :bucket_name

    def create_bucket
      RAWS::S3.create_bucket(self.bucket_name)
    end

    def delete_bucket(force=nil)
      RAWS::S3.delete_bucket(self.bucket_name, force)
    end
  end

  module InstanceMethods
    def after_initialize; end
    def before_delete; end
    def after_delete; end
    def before_save; end
    def after_save; end
    def before_update; end
    def after_update; end
    def before_insert; end
    def after_insert; end
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end

  class Metadata < Hash
    X_AMZ_META = 'x-amz-meta-'

    def initialize(object)
      super()
      @object = object
      decode(@object.header)
    end

    def decode(header)
      header.select do |key, val|
        key.match(/^#{X_AMZ_META}/)
      end.each do |key, val|
        self[key.sub(X_AMZ_META, '')] = begin
          a = val.split(',').map do |val|
            RAWS.unescape(val)
          end
          1 < a.size ? a : a.first
        end
      end
    end

    def encode
      self.inject({}) do |ret, (key, val)|
        key = X_AMZ_META + key

        if val.is_a? Array
          ret[key] = val.map do |v|
            RAWS.escape(v.strip)
          end.join(',')
        else
          ret[key] = RAWS.escape(val.strip)
        end

        ret
      end
    end
  end
end
