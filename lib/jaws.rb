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
    attr_reader :data

    def initialize(data)
      super()
      @data = data
    end
  end

  class << self
    attr_accessor :aws_access_key_id
    attr_accessor :aws_secret_access_key
  end

  def self.escape(val)
    URI.escape(val.to_s, /([^a-zA-Z0-9\-_.~]+)/n)
  end

  def self.sign(http_verb, base_uri, params)
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

  def self.parse(doc, ret={})
    doc.children.each do |tag|
      name = tag.name #.gsub(/([A-Z])/, '_\1').gsub(/^_/, '').downcase.to_sym

      if tag.child.is_a? Nokogiri::XML::Text
        if ret.key? name
          ret[name] = [ret[name]] unless ret[name].is_a? Array
          ret[name] << tag.content
        else
          ret[name] = tag.content
        end
      else
        if ret.key? name
          ret[name] = [ret[name], {}] unless ret[name].is_a? Array
          ret[name] << {}
          parse(tag, ret[name].last)
        else
          ret[name] = {}
          parse(tag, ret[name])
        end
      end
    end

    ret
  end

  def self.send(http_verb, base_uri, params)
    get\
      "#{base_uri}?#{sign(http_verb, base_uri, params)}",
      :on_success => lambda { |r|
        parse(Nokogiri::XML.parse(r.body))
      },
      :on_failure => lambda { |r|
        raise Error.new(parse(Nokogiri::XML.parse(r.body)))
      }
  end

  autoload :SDB, 'jaws/sdb'
  autoload :SQS, 'jaws/sqs'
end
