module RAWS::S3::Model
  module ClassMethods
    attr_accessor :bucket_name

    def create_bucket
      RAWS::S3.create_bucket(self.bucket_name)
    end

    def delete_bucket(force=nil)
      RAWS::S3.delete_bucket(self.bucket_name, force)
    end

    def filter(query={})
      RAWS::S3.filter(self.bucket_name, query).map do |val|
        self.new(val['Key'])
      end
    end
    alias :all :filter

    def find(key, header={})
      begin
        self.new(key, RAWS::S3.head(self.bucket_name, key).header)
      rescue RAWS::HTTP::Error => e
        if e.response.code == 404
          nil
        else
          raise e
        end
      end
    end
  end

  module InstanceMethods
    attr_reader :key

    def initialize(key, header=nil)
      @key, @metadata, @header = key, Metadata.new(header || {}), header
      after_initialize
    end

    def header
      begin
        @header = RAWS::S3.head(self.class.bucket_name, @key).header
      rescue RAWS::HTTP::Error => e
        if e.response.code == 404
          {}
        else
          raise e
        end
      end
    end

    def metadata
      @header ? @metadata : @metadata.decode(header)
    end

    def receive(header={}, &block)
      RAWS::S3.get(
        self.class.bucket_name,
        @key,
        header
      ) do |request|
        response = request.send
        response.receive(&block)
        @metadata.decode(response.header)
        response
      end
    end

    def send(header={}, &block)
      RAWS::S3.put(
        self.class.bucket_name,
        @key,
        @metadata.encode.merge!(header)
      ) do |request|
        request.send(&block)
      end
    end

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

    def initialize(header={})
      super()
      decode(header)
    end

    def decode(header)
      clear
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
      self
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
