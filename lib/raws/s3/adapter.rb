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

    def sign(http_verb, header, path)
      "#{RAWS.aws_access_key_id}:#{
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA1.new,
            RAWS.aws_secret_access_key,
            (
              [
                http_verb,
                header['content-md5'],
                header['content-type'],
                header['date']
              ] + header.select do |key, val|
                /^x-amz-/.match(key)
              end.map do |key,val|
                "#{key}:#{val}"
              end + [
                path
              ]
            ).join("\n")
          )
        ].pack('m').strip
      }"
    end

    def normalize_params(http_verb, _params={}, _header={}, content=nil)
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

      header = _header.merge({'date' => Time.now.httpdate })
      header['authorization'] = 'AWS ' << sign(http_verb, header, sign_path)

      [
        build_uri(params),
        {
          :headers => header,
          :body    => content
        }
      ]
    end

    def fetch(http_verb, params={}, options={}, content=nil, header={})
      r = RAWS.__send__(
        http_verb.downcase.to_sym,
        *normalize_params(http_verb, params, header, content)
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

    def put_bucket(bucket_name, location=nil, header={})
      fetch(
        'PUT',
        {
          :bucket => bucket_name
        },
        {},
        nil,
        header
      )
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

    def put_object(bucket_name, name, object, header={})
      fetch(
        'PUT',
        {
          :bucket => bucket_name,
          :path   => '/' << name
        },
        {},
        object,
        header
      )
    end

    def copy_object(src_bucket, src_name, dest_bucket, dest_name, header={})
      fetch(
        'PUT',
        {
          :bucket => dest_bucket,
          :path   => '/' << dest_name
        },
        {},
        nil,
        header.merge('x-amz-copy-source' => "/#{src_bucket}/#{src_name}")
      )
    end

    def get_object(bucket_name, name)
      r = RAWS.get(
        *normalize_params(
          'GET',
          {
            :bucket => bucket_name,
            :path   => '/' << name
          }
        )
      )
      if 200 <= r.code && r.code <= 299
        r
      else
        raise RAWS::Error.new(r)
      end
    end

    def head_object(bucket_name, name)
      r = RAWS.head(
        *normalize_params(
          'HEAD',
          {
            :bucket => bucket_name,
            :path   => '/' << name
          }
        )
      )
      if 200 <= r.code && r.code <= 299
        r
      else
        raise RAWS::Error.new(
          r,
          RAWS.parse(Nokogiri::XML.parse(r.body))
        )
      end
    end

    def delete_object(bucket_name, name)
      fetch(
        'DELETE',
        {
          :bucket => bucket_name,
          :path   => '/' << name
        }
      )
    end

    def get_acl(bucket_name, name)
      fetch(
        'GET',
        {
          :bucket => bucket_name,
          :path   => '/' << name,
          :query  => 'acl'
        },
        :multiple => ['Grant']
      )
    end
  end

  extend Adapter20060301
end
