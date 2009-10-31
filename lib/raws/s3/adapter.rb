class RAWS::S3::Adapter
  module Adapter20060301
    URI_PARAMS = {
      :scheme => 'https',
      :host   => 's3.amazonaws.com',
      :path   => '/',
      :query  => {}
    }

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

    def fetch(http_verb, params={}, header={}, content=nil, parser={})
      params = URI_PARAMS.merge(params)

      path = if bucket = params[:bucket]
        if bucket.include?('.')
          params.delete(:bucket)
          params[:path] = "/#{bucket}#{params[:path]}"
        else
          "/#{bucket}#{params[:path]}"
        end
      else
        params[:path]
      end

      unless params[:query].empty?
        params[:path] += '?' << params[:query].map do |key, val|
          val ? "#{RAWS.escape(key)}=#{RAWS.escape(val)}" : RAWS.escape(key)
        end.sort.join(';')

        %w'acl location logging torrent'.each do |val|
          if params[:query].key?(val)
            path << "?#{val}"
            break
          end
        end
      end

      header['date'] = Time.now.httpdate
      header['authorization'] = 'AWS ' << sign(http_verb, header, path)

      params[:host] = "#{params[:bucket]}.#{params[:host]}" if params[:bucket]

      RAWS.http.fetch(
        http_verb,
        "#{params[:scheme]}://#{params[:host]}#{params[:path]}",
        header,
        content,
        parser
      )
    end

    def get_service
      fetch('GET', {}, {}, nil, {:multiple => ['Bucket']})
    end

    def put_bucket(bucket_name, location=nil, header={})
      fetch(
        'PUT',
        {
          :bucket => bucket_name
        },
        header,
        if location
          "<CreateBucketConfiguration><LocationConstraint>#{
            location
          }</LocationConstraint></CreateBucketConfiguration>"
        else
          nil
        end
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
        {},
        nil,
        {
          :multiple => ['Contents']
        }
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
      fetch('DELETE', {:bucket => bucket_name})
    end

    def put_object(bucket_name, name, object, header={})
      fetch(
        'PUT',
        {
          :bucket => bucket_name,
          :path   => '/' << name
        },
        header,
        object
      )
    end

    def copy_object(src_bucket, src_name, dest_bucket, dest_name, header={})
      fetch(
        'PUT',
        {
          :bucket => dest_bucket,
          :path   => '/' << dest_name
        },
        header.merge('x-amz-copy-source' => "/#{src_bucket}/#{src_name}")
      )
    end

    def get_object(bucket_name, name=nil, params={})
      fetch(
        'GET',
        {
          :bucket => bucket_name,
          :path   => "/#{name}",
          :query  => params[:query] || {}
        },
        params[:header] || {},
        nil,
        params[:parser]
      )
    end

    def head_object(bucket_name, name)
      fetch(
        'HEAD',
        {
          :bucket => bucket_name,
          :path   => '/' << name
        },
        {},
        nil,
        nil
      )
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
  end

  extend Adapter20060301
end
