require 'uri'
require 'time'
require 'openssl'

require 'rubygems'
require 'typhoeus'
require 'nokogiri'

path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

module RAWS
  include Typhoeus

  class Error < StandardError
    attr_reader :request
    attr_reader :data

    def initialize(request, data)
      super()
      @request, @data = request, data
    end
  end

  class << self
    attr_accessor :aws_access_key_id
    attr_accessor :aws_secret_access_key

    def escape(val)
      URI.escape(val.to_s, /([^a-zA-Z0-9\-_.~]+)/n)
    end

    def sign(http_verb, base_uri, params)
      path = {
        'AWSAccessKeyId'   => aws_access_key_id,
        'SignatureMethod'  => 'HmacSHA256',
        'SignatureVersion' => '2',
        'Timestamp'        => Time.now.utc.iso8601
      }.merge(params).map do |key, val|
        "#{escape(key)}=#{escape(val)}"
      end.sort.join('&')

      uri = URI.parse(base_uri)
      "#{path}&Signature=" + escape(
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA256.new,
            aws_secret_access_key,
            "#{http_verb.upcase}\n#{uri.host.downcase}\n#{uri.path}\n#{path}"
          )
        ].pack('m').strip
      )
    end

    def pack_attrs(attrs, replaces=nil, prefix=nil)
      params = {}

      i = 1
      attrs.each do |key, val|
        if !replaces.nil? && replaces.include?(key)
          params["#{prefix}Attribute.#{i}.Replace"] = 'true'
        end

        if val.is_a? Array
          val.each do |v|
            params["#{prefix}Attribute.#{i}.Name"]  = key
            params["#{prefix}Attribute.#{i}.Value"] = v
            i += 1
          end
        else
          params["#{prefix}Attribute.#{i}.Name"]  = key
          params["#{prefix}Attribute.#{i}.Value"] = val
          i += 1
        end
      end

      params
    end

    def unpack_attrs(attrs)
      ret = {}

      if attrs.is_a? Array
        attrs
      else
        [attrs]
      end.map do |val|
        name, value = val['Name'], val['Value']

        if ret.key? name
          ret[name] = [ret[name]] unless ret[name].is_a? Array
          ret[name] << value
        else
          ret[name] = value
        end
      end if attrs

      ret
    end

    def parse(doc, params={}, ret={})
      multiple = params[:multiple] || []
      unpack   = params[:unpack]   || []

      name = nil
      doc.children.each do |tag|
        name = tag.name #.gsub(/([A-Z])/, '_\1').gsub(/^_/, '').downcase.to_sym

        unless ret[name].is_a? Array
          if ret.key?(name)
            ret[name] = [ret[name]]
          elsif multiple.include? name
            ret[name] = []
          end
        end

        if tag.child.is_a? Nokogiri::XML::Text
          if ret.key? name
            ret[name] << tag.content
          else
            ret[name] = tag.content
          end
        else
          if ret.key? name
            ret[name] << {}
            parse(tag, params, ret[name].last)
          else
            ret[name] = {}
            parse(tag, params, ret[name])
          end
        end
      end
      ret[name] = unpack_attrs(ret[name]) if unpack.include?(name)

      ret
    end

    def fetch(http_verb, base_uri, params, options={})
      r = get("#{base_uri}?#{sign(http_verb, base_uri, params)}")
      if 200 <= r.code && r.code <= 300
        parse(Nokogiri::XML.parse(r.body), options)
      else
        raise Error.new(r, parse(Nokogiri::XML.parse(r.body)))
      end
    end
  end

  autoload :SDB, 'raws/sdb'
  autoload :SQS, 'raws/sqs'
  autoload :S3,  'raws/s3'
end
