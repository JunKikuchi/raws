require 'uri'
require 'time'
require 'logger'
require 'openssl'
require 'rubygems'

module RAWS
  class << self
    attr_accessor :aws_access_key_id
    attr_accessor :aws_secret_access_key

    def escape(val)
      URI.escape(val.to_s, /([^a-zA-Z0-9\-_.~]+)/n)
    end

    def unescape(val)
      URI.unescape(val.to_s)
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
      "#{path}&Signature=" << escape(
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA256.new,
            aws_secret_access_key,
            "#{http_verb.upcase}\n#{uri.host.downcase}\n#{uri.path}\n#{path}"
          )
        ].pack('m').strip
      )
    end

    def fetch(http_verb, base_uri, params, options={})
      http.fetch(
        http_verb,
        "#{base_uri}?#{sign(http_verb, base_uri, params)}",
        {},
        nil,
        options
      ).doc
    end

    def http
      @http ||= HTTP::Typhoeus.new
    end

    def xml
      @xml ||= XML::Nokogiri.new
    end

    def logger
      @logger ||= begin
        logger = Logger.new(STDERR)
        logger.progname = self.name
        logger.level = Logger::INFO
        def logger.debug(val)
          require 'yaml'
          super(val.to_yaml)
        end
        logger
      end
    end
  end

  autoload :HTTP, 'raws/http'
  autoload :XML,  'raws/xml'

  autoload :SDB,  'raws/sdb'
  autoload :SQS,  'raws/sqs'
  autoload :S3,   'raws/s3'
end
