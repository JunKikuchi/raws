require 'uri'
require 'time'
require 'openssl'

require 'rubygems'
require 'typhoeus'
require 'nokogiri'

path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

module JAWS
  include Typhoeus

  class Error < StandardError
    attr_reader :response
    attr_reader :data

    def initialize(response, data)
      super()
      @response, @data = response, data
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
            ::OpenSSL::Digest::Digest.new("sha256"),
            aws_secret_access_key,
            "#{http_verb.upcase}\n#{uri.host.downcase}\n#{uri.path}\n#{path}"
          )
        ].pack('m').strip
      )
    end

    def parse(doc, multi=[], ret={})
      doc.children.each do |tag|
        name = tag.name #.gsub(/([A-Z])/, '_\1').gsub(/^_/, '').downcase.to_sym

        unless ret[name].is_a? Array
          if ret.key?(name)
            ret[name] = [ret[name]]
          elsif multi.include? name
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
            parse(tag, multi, ret[name].last)
          else
            ret[name] = {}
            parse(tag, multi, ret[name])
          end
        end
      end

      ret
    end

    def fetch(http_verb, base_uri, params, multi=[])
      get(
        "#{base_uri}?#{sign(http_verb, base_uri, params)}",
        :on_success => lambda { |r|
          parse(Nokogiri::XML.parse(r.body), multi)
        },
        :on_failure => lambda { |r|
          raise Error.new(r, parse(Nokogiri::XML.parse(r.body)))
        }
      )
    end
  end

  autoload :SDB, 'jaws/sdb'
  autoload :SQS, 'jaws/sqs'
end
