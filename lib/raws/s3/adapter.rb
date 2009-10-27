class RAWS::S3::Adapter
  module Adapter20060301
    URI_PARAMS = {
      :scheme => 'https',
      :host   => 's3.amazonaws.com',
      :path   => '/',
      :query  => {}
    }

    class Response
      attr_reader :code
      attr_reader :header
      attr_reader :body

      def initialize(response)
        @code = response.code
        headers = response.headers.split("\r\n")
        headers.delete_at(0)
        @header = Hash[
          *headers.map do |val|
            md = /(.+?):\s*(.*)/.match(val)
            [md[1].downcase, md[2]]
          end.flatten
        ]
        @body = response.body
      end
    end

    class Redirect < StandardError
      attr_reader :response

      def initialize(response)
        @response = Response.new(response)
      end
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

    def fetch(http_verb, params, header={}, content=nil)
      request = URI_PARAMS.merge(params[:request] || {})

      request[:path] += '?' << request[:query].map do |key, val|
        val ? "#{RAWS.escape(key)}=#{RAWS.escape(val)}" : RAWS.escape(key)
      end.sort.join(';') unless request[:query].empty?

      header['date'] = Time.now.httpdate
      header['authorization'] = 'AWS ' << sign(
        http_verb,
        header,
        if bucket = request[:bucket]
          if bucket.include?('.')
            request.delete(:bucket)
            request[:path] = "/#{bucket}#{request[:path]}"
          else
            "/#{bucket}#{request[:path]}"
          end
        else
           request[:path]
        end
      )

      if request[:bucket]
        request[:host] = "#{request[:bucket]}.#{request[:host]}"
      end

      uri = "#{request[:scheme]}://#{request[:host]}#{request[:path]}"

      begin
        r = RAWS.__send__(
          http_verb.downcase.to_sym,
          uri,
          {
            :headers => header,
            :body    => content
          }
        )

        if 200 <= r.code && r.code <= 299
          if params[:noparse]
            Response.new(r)
          else
            RAWS.parse(Nokogiri::XML.parse(r.body), params[:parser] || {})
          end
        elsif 300 <= r.code && r.code <= 399
          raise Redirect.new(r)
        else
          raise RAWS::Error.new(r, RAWS.parse(Nokogiri::XML.parse(r.body)))
        end
      rescue Redirect => e
        uri = e.response.header['location']
        retry
      end
    end

    def get_service
      fetch('GET', :parser => {:multiple => ['Bucket']})
    end

    def put_bucket(bucket_name, location=nil, header={})
      fetch(
        'PUT',
        {:request => {:bucket => bucket_name}},
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
        :request => {
          :bucket => bucket_name,
          :query  => {'requestPayment' => nil}
        }
      )
    end

    def get_bucket(bucket_name, params={})
      fetch(
        'GET',
        :request => {
          :bucket => bucket_name,
          :query  => params
        },
        :parser => {
          :multiple => ['Contents']
        }
      )
    end

    def get_request_payment(bucket_name)
      fetch(
        'GET',
        :request => {
          :bucket => bucket_name,
          :query  => {'requestPayment' => nil}
        }
      )
    end

    def get_bucket_location(bucket_name)
      fetch(
        'GET',
        :request => {
          :bucket => bucket_name,
          :query  => {'location' => nil}
        }
      )
    end

    def delete_bucket(bucket_name)
      fetch('DELETE', :request => {:bucket => bucket_name})
    end

    def put_object(bucket_name, name, object, header={})
      fetch(
        'PUT',
        {
          :request => {
            :bucket => bucket_name,
            :path   => '/' << name
          }
        },
        header,
        object
      )
    end

    def copy_object(src_bucket, src_name, dest_bucket, dest_name, header={})
      fetch(
        'PUT',
        {
          :request => {
            :bucket => dest_bucket,
            :path   => '/' << dest_name
          }
        },
        header.merge('x-amz-copy-source' => "/#{src_bucket}/#{src_name}")
      )
    end

    def get_object(bucket_name, name)
      fetch(
        'GET',
        :request => {
          :bucket => bucket_name,
          :path   => '/' << name
        },
        :noparse => true
      )
    end

    def head_object(bucket_name, name)
      fetch(
        'HEAD',
        :request => {
          :bucket => bucket_name,
          :path   => '/' << name
        },
        :noparse => true
      )
    end

    def delete_object(bucket_name, name)
      fetch(
        'DELETE',
        :request => {
          :bucket => bucket_name,
          :path   => '/' << name
        }
      )
    end

    def get_acl(bucket_name, name)
      fetch(
        'GET',
        :request => {
          :bucket => bucket_name,
          :path   => '/' << name,
          :query  => 'acl'
        },
        :parser => {
          :multiple => ['Grant']
        }
      )
    end
  end

  extend Adapter20060301
end
