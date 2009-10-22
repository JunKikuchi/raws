require 'digest/md5'

class RAWS::S3::Adapter
  module Adapter20060301
    URI_PARAMS = {
      :scheme => 'https',
      :host   => 's3.amazonaws.com',
      :path   => '/',
      :query  => {}
    }

    def build_uri(params={})
      "#{params[:scheme]}://#{
        if params[:bucket]
          "#{params[:bucket]}.#{params[:host]}"
        else
          params[:host]
        end
      }#{params[:path]}"
    end

    def sign(http_verb, content, header, path)
      "#{RAWS.aws_access_key_id}:#{
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA1.new,
            RAWS.aws_secret_access_key,
            [
              http_verb,
              content ? Digest::MD5.hexdigest(content) : '',
              header['Content-Type'],
              header['Date'],
              path
            ].join("\n")
          )
        ].pack('m').strip
      }"
    end

    def fetch(http_verb, _params={}, options={}, content=nil, _header={})
      params = URI_PARAMS.merge(_params)

      params[:path] += '?' << params[:query].map do |key, val|
        val ? "#{RAWS.escape(key)}=#{RAWS.escape(val)}" : RAWS.escape(key)
      end.sort.join(';') unless params[:query].empty?

      sign_path = if bucket = params[:bucket]
        if bucket.include?('.')
          params.delete(:bucket)
          params[:path] = "/#{bucket}#{params[:path]}"
        else
          "/#{bucket}#{params[:path]}"
        end
      else
        params[:path]
      end

      header = _header.merge({'Date' => Time.now.httpdate })
      header['Authorization'] = "AWS #{
        sign(http_verb, content, header, sign_path)
      }"

      r = RAWS.__send__(
        http_verb.downcase.to_sym,
        build_uri(params),
        :headers => header
      )
      data = RAWS.parse(Nokogiri::XML.parse(r.body), options)
      if 200 <= r.code && r.code <= 299
        data
      else
        raise RAWS::Error.new(r, data)
      end
    end

    def get_service
      fetch('GET', {}, :multiple => ['Bucket'])
    end

    def put_bucket(bucket_name, location=nil)
      fetch('PUT', :bucket => bucket_name)
    end

    def put_request_payment(bucket_name)
      fetch(
        'PUT',
        {
          :bucket => bucket_name,
          :query  => {'requestPayment' => nil}
        }
      )
    end

    def get_bucket(bucket_name, params={})
      fetch(
        'GET',
        {
          :bucket => bucket_name,
          :query  => params
        },
        :multiple => ['Contents']
      )
    end

    def get_request_payment(bucket_name)
      fetch(
        'GET',
        {
          :bucket => bucket_name,
          :query  => {'requestPayment' => nil}
        }
      )
    end

    def get_bucket_location(bucket_name)
      fetch(
        'GET',
        {
          :bucket => bucket_name,
          :query  => {'location' => nil}
        }
      )
    end

    def delete_bucket(bucket_name)
      fetch('DELETE', :bucket => bucket_name)
    end

    def put_object(bucket_name, object, header)
      fetch(
        'PUT',
        {:bucket => bucket_name},
        {},
        object,
        header
      )
    end
  end

  extend Adapter20060301
end
