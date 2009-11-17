class RAWS::SDB::Adapter
  module Adapter20090415
    URI = 'https://sdb.amazonaws.com/'
    PARAMS = {'Version' => '2009-04-15'}
    KEYWORDS = %w'
      or and not from where select like null is order by asc desc in between
      intersection limit every
    '
    REXP_NAME = /^[a-zA-Z_$]/

    def pack_attrs(attrs, replaces=nil, prefix=nil)
      params = {}

      i = 1
      attrs.each do |key, val|
        if !replaces.nil? && replaces.include?(key)
          params["#{prefix}Attribute.#{i}.Replace"] = 'true'
        end

        if val.is_a? Array
          val.each do |v|
            params["#{prefix}Attribute.#{i}.Name"]  = key
            params["#{prefix}Attribute.#{i}.Value"] = v
            i += 1
          end
        else
          params["#{prefix}Attribute.#{i}.Name"]  = key
          params["#{prefix}Attribute.#{i}.Value"] = val
          i += 1
        end
      end

      params
    end

    def sign(method, base_uri, params)
      path = {
        'AWSAccessKeyId'   => RAWS.aws_access_key_id,
        'SignatureMethod'  => 'HmacSHA256',
        'SignatureVersion' => '2',
        'Timestamp'        => Time.now.utc.iso8601
      }.merge(params).map do |key, val|
        "#{RAWS.escape(key)}=#{RAWS.escape(val)}"
      end.sort.join('&')

      uri = ::URI.parse(base_uri)
      "#{path}&Signature=" << RAWS.escape(
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA256.new,
            RAWS.aws_secret_access_key,
            "#{method.upcase}\n#{uri.host.downcase}\n#{uri.path}\n#{path}"
          )
        ].pack('m').strip
      )
    end

    def connect(method, base_uri, params, parser={})
      doc = nil

      RAWS.http.connect(
        "#{base_uri}?#{sign(method, base_uri, params)}"
      ) do |request|
        request.method = method
        response = request.send
        doc = response.parse(parser)
        response
      end

      doc
    end

    def create_domain(domain_name)
      params = {
        'Action'     => 'CreateDomain',
        'DomainName' => domain_name
      }

      connect('GET', URI, PARAMS.merge(params))
    end

    def delete_domain(domain_name)
      params = {
        'Action'     => 'DeleteDomain',
        'DomainName' => domain_name
      }

      connect('GET', URI, PARAMS.merge(params))
    end

    def domain_metadata(domain_name)
      params = {
        'Action'     => 'DomainMetadata',
        'DomainName' => domain_name
      }

      connect('GET', URI, PARAMS.merge(params))
    end

    def list_domains(next_token=nil, max_num=nil, &block)
      params = {'Action' => 'ListDomains'}
      params['NextToken']          = next_token if next_token
      params['MaxNumberOfDomains'] = max_num    if max_num

      connect('GET', URI, PARAMS.merge(params), :multiple => %w'DomainName')
    end

    def get_attributes(domain_name, item_name, *attrs)
      params = {
        'Action'     => 'GetAttributes',
        'DomainName' => domain_name,
        'ItemName'   => item_name
      }

      i = 0
      attrs.each do |name|
        params["AttributeName.#{i}"] = name
        i += 1
      end

      connect(
        'GET',
        URI,
        PARAMS.merge(params),
        :multiple => %w'Attribute',
        :unpack   => %w'Attribute'
      )
    end

    def put_attributes(domain_name, item_name, attrs={}, *replaces)
      params = {
        'Action'     => 'PutAttributes',
        'DomainName' => domain_name,
        'ItemName'   => item_name
      }
      params.merge!(pack_attrs(attrs, replaces))

      connect('GET', URI, PARAMS.merge(params))
    end

    def batch_put_attributes(domain_name, items={}, replaces={})
      params = {
        'Action'     => 'BatchPutAttributes',
        'DomainName' => domain_name
      }
      
      i = 0
      items.each do |key, attrs|
        params["Item.#{i}.ItemName"] = key
        params.merge!(pack_attrs(attrs, replaces[key], "Item.#{i}."))
        i += 1
      end

      connect('GET', URI, PARAMS.merge(params))
    end

    def delete_attributes(domain_name, item_name, attrs={})
      params = {
        'Action'     => 'DeleteAttributes',
        'DomainName' => domain_name,
        'ItemName'   => item_name
      }
      params.merge!(pack_attrs(attrs))

      connect('GET', URI, PARAMS.merge(params))
    end

    def quote(val)
      if !REXP_NAME.match(val) || KEYWORDS.include?(val)
        "'#{val}'"
      else
        val
      end
    end

    def query_expr(expr, *params)
      expr.gsub(/(\\)?(\?)/) do
        if $1
          "?"
        else
          "'#{params.shift.to_s.gsub(/(['])/, '\1\1')}'"
        end
      end
    end

    def select(expr, expr_params=[], next_token=nil)
      params = {
        'Action'           => 'Select',
        'SelectExpression' => query_expr(expr, *expr_params)
      }
      params['NextToken'] = next_token if next_token

      connect(
        'GET',
        URI,
        PARAMS.merge(params),
        :multiple => %w'Item Attribute',
        :unpack   => %w'Attribute'
      )
    end
  end

  extend Adapter20090415
end
