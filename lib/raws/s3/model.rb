require 'forwardable'

module RAWS::S3::Model
  module ClassMethods
    include Enumerable
    extend Forwardable
    def_delegators :bucket,
      :create_bucket,
      :delete_bucket,
      :owner,
      :location,
      :acl,
      :put_object,
      :put,
      :copy_object,
      :copy,
      :get_object,
      :get,
      :delete_object,
      :delete

    attr_accessor :bucket_name

    def head_object(key)
      begin
        bucket.head_object(key).header
      rescue => e
        if e.response.code == 404
          {}
        else
          raise e
        end
      end
    end
    alias :head :head_object

    def bucket
      RAWS::S3[bucket_name]
    end

    def filter(query={}, &block)
      bucket.filter(query) do |contents|
        block.call self.new(contents['Key'])
      end
    end
    alias :all :filter
    alias :each :filter

    def find(key)
      self.new key, head(key)
    end
  end

  module InstanceMethods
    attr_reader :key

    def initialize(key, header=nil)
      @key, @header, @metadata = key, header, nil
      after_initialize
    end

    def header
      @header ||= self.class.head(@key)
    end

    def metadata
      @metadata ||= RAWS::S3::Metadata.new header
    end

    def acl
      self.class.acl @key
    end

    def delete
      before_delete
      response = self.class.delete_object @key
      after_delete response
    end

    def send(header={}, &block)
      before_send
      @header.merge! header
      response = self.class.put_object(
        @key,
        @header.merge(metadata.encode)
      ) do |request|
        request.send &block
      end
      after_send response
    end

    def receive(header={}, &block)
      before_receive
      after_send(
        self.class.get_object(@key, header) do |request|
          response = request.send
          @header  = response.header
          @metadata.decode @header
          response.receive &block
          response
        end
      )
    end

    def after_initialize; end
    def before_delete; end
    def after_delete(response); end
    def before_receive; end
    def after_receive(response); end
    def before_send; end
    def after_send(response); end
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
end
