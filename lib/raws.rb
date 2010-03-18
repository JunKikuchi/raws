require 'uri'
require 'time'
require 'logger'
require 'openssl'
require 'rubygems'

module RAWS
  class << self
    attr_accessor :aws_access_key_id
    attr_accessor :aws_secret_access_key
    attr_accessor :http
    attr_accessor :xml
  end

  def self.escape(val)
    URI.escape(val.to_s)
  end

  def self.unescape(val)
    URI.unescape(val.to_s)
  end

  def self.logger
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

  autoload :HTTP, 'raws/http'
  autoload :XML, 'raws/xml'

  autoload :SDB, 'raws/sdb'
  autoload :SQS, 'raws/sqs'
  autoload :S3, 'raws/s3'
end

RAWS.http = RAWS::HTTP::HT2P
RAWS.xml  = RAWS::XML::Nokogiri
