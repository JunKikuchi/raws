class RAWS::S3::Adapter
  module Adapter20060301
    URI_PARAMS = {
      :scheme => 'https',
      :host   => 's3.amazonaws.com',
      :path   => '/',
      :query  => {}
    }

    def parse_params(params)
      params = URI_PARAMS.merge(params)

      path = if bucket = params[:bucket]
        if bucket.include?('.')
          params.delete :bucket
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

        params[:query].each do |key, val|
          unless val
            path << "?#{key}"
            break
          end
        end
      end

      [
        "#{params[:scheme]}://#{
          if params[:bucket]
            "#{params[:bucket]}.#{params[:host]}"
          else
            params[:host]
          end
        }#{params[:path]}",
        path
      ]
    end
    private :parse_params

    def sign(request, path)
      request.header['authorization'] = "AWS #{RAWS.aws_access_key_id}:#{
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA1.new,
            RAWS.aws_secret_access_key,
            (
              [
                request.method,
                request.header['content-md5'],
                request.header['content-type'],
                request.header['x-amz-date'] ? '' : request.header['date'],
              ] + request.header.select do |key, val|
                /^x-amz-/.match(key)
              end.sort.map do |key, val|
                "#{key}:#{val}"
              end + [
                path
              ]
            ).join("\n")
          )
        ].pack('m').strip
      }"
    end
    private :sign

    def connect(method, params={}, &block)
      uri, path = parse_params params
      RAWS.http.connect(uri) do |request|
        request.method = method
        request.header['date'] = Time.now.httpdate
        request.before_send do |_request|
          sign _request, path
        end
        block.call request
      end
    end

    def get_service
      connect 'GET' do |request|
        response = request.send
        response.parse :multiple => ['Bucket']
        response
      end
    end

    def put_bucket(bucket_name, location=nil, header={})
      connect 'PUT', :bucket => bucket_name do |request|
        request.header.merge! header
        response = request.send(
          if location
            "<CreateBucketConfiguration>"
              "<LocationConstraint>#{
                location
              }</LocationConstraint>"
            "</CreateBucketConfiguration>"
          end
        )
        response.receive
        response
      end
    end

    def put_request_payment(bucket_name, requester)
      connect(
        'PUT', 
        :bucket => bucket_name,
        :query  => {'requestPayment' => nil}
      ) do |request|
        response = request.send\
          '<RequestPaymentConfiguration'
            ' xmlns="http://s3.amazonaws.com/doc/2006-03-01/">'
            "<Payer>#{requester}</Payer>"
          '</RequestPaymentConfiguration>'
        response.receive
        response
      end
    end

    def get_bucket(bucket_name, params={})
      connect(
        'GET', 
        :bucket => bucket_name,
        :query  => params
      ) do |request|
        response = request.send
        response.parse :multiple => ['Contents']
        response
      end
    end

    def get_request_payment(bucket_name)
      connect(
        'GET', 
        :bucket => bucket_name,
        :query  => {'requestPayment' => nil}
      ) do |request|
        response = request.send
        response.parse
        response
      end
    end

    def get_bucket_location(bucket_name)
      connect(
        'GET', 
        :bucket => bucket_name,
        :query  => {'location' => nil}
      ) do |request|
        response = request.send
        response.parse
        response
      end
    end

    def delete_bucket(bucket_name)
      connect 'DELETE', :bucket => bucket_name do |request|
        request.send
      end
    end

    def put_object(bucket_name, name, header, &block)
      connect(
        'PUT',
        :bucket => bucket_name,
        :path   => '/' << name
      ) do |request|
        request.header.merge!(header)
        response = request.send(&block)
        response.receive
        response
      end
    end

    def copy_object(src_bucket, src_name, dest_bucket, dest_name, header={})
      connect(
        'PUT',
        :bucket => dest_bucket,
        :path   => '/' << dest_name
      ) do |request|
        request.header.merge! header
        request.header['x-amz-copy-source'] = "/#{src_bucket}/#{src_name}"
        request.send
      end
    end

    def get_object(bucket_name, name=nil, header={}, &block)
      connect(
        'GET',
        :bucket => bucket_name,
        :path   => "/#{name}"
      ) do |request|
        request.header.merge! header
        response = request.send
        response.receive(&block)
        response
      end
    end

    def head_object(bucket_name, name)
      connect(
        'HEAD',
        :bucket => bucket_name,
        :path   => '/' << name
      ) do |request|
        response = request.send
        response.receive
        response
      end
    end

    def delete_object(bucket_name, name)
      connect(
        'DELETE',
        :bucket => bucket_name,
        :path   => '/' << name
      ) do |request|
        response = request.send
        response.receive
        response
      end
    end
  end

  extend Adapter20060301
end
