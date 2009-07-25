require 'digest/md5'

class RAWS::S3::Adapter
  module Adapter20060301
    URI = 'https://s3.amazonaws.com/'

    def sign(http_verb, content, type, date, path)
      "AWS #{RAWS.aws_access_key_id}:#{
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::Digest.new("sha1"),
            RAWS.aws_secret_access_key,
            [
              http_verb,
              content ? Digest::MD5.hexdigest(content) : '',
              type,
              date,
              "/#{path}"
            ].join("\n")
          )
        ].pack('m').strip
      }"
    end

    def fetch(http_verb, base_uri, path, content, type, options={})
      date = Time.now.httpdate
      RAWS.get(
        base_uri + path,
        :headers => {
          'Date'          => date,
          'Authorization' => sign(http_verb, content, type, date, path)
        },
        :on_success => lambda { |r|
          RAWS.parse(Nokogiri::XML.parse(r.body), options)
        },
        :on_failure => lambda { |r|
          raise RAWS::Error.new(r, RAWS.parse(Nokogiri::XML.parse(r.body)))
        }
      )
    end

    def list_backets
      fetch('GET', URI, '', nil, '', :multiple => 'Bucket')
    end
  end

  extend Adapter20060301
end
