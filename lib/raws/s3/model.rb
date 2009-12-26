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
        self.new val['Key'], {}, true
      end
    end
    alias :all :filter

    def find(key, header={})
      begin
        self.new key, {}, true
      rescue RAWS::HTTP::Error => e
        if e.response.code == 404
          nil
        else
          raise e
        end
      end
    end

    def acl
      RAWS::S3.acl(self.bucket_name)
    end
  end

  module InstanceMethods
    attr_reader :key

    def initialize(key, header={}, exists=false)
      @key, @exists = key, exists
      @header = RAWS::S3::Header.new(self.class.bucket_name, key, header)
      @metadata, @acl = nil, nil
      after_initialize
    end

    def exists?
      @exists
    end

    def header
      begin
        exists? && @header.reload
      rescue RAWS::HTTP::Error => e
        if e.response.code == 404
          @exists = false
        else
          raise
        end
      end
      @header
    end

    def metadata
      @metadata ||= RAWS::S3::Metadata.new(header)
    end

    def acl
      @acl ||= RAWS::S3.acl(self.class.bucket_name, @key)
    end

    def delete
      RAWS::S3.delete(self.class.bucket_name, @key)
      @exists = false
    end

    def receive(header={}, &block)
      RAWS::S3.get(
        self.class.bucket_name,
        @key,
        header
      ) do |request|
        response = request.send
        response.receive(&block)
        metadata.decode(response.header)
        response
      end
    end

    def send(header={}, &block)
      ret = RAWS::S3.put(
        self.class.bucket_name,
        @key,
        metadata.encode.merge!(header)
      ) do |request|
        request.send(&block)
      end
      @exists = true
      ret
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
end
