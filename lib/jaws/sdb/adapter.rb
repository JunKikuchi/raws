class JAWS::SDB::Adapter
  module Adapter20090415
    URI = 'https://sdb.amazonaws.com/'
    PARAMS = {'Version' => '2009-04-15'}
    KEYWORDS = %w'or and not from where select like null is order by asc desc in between intersection limit every'
    REXP_NAME = /^[a-zA-Z_$]/

    def create_domain(domain_name)
      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge('Action' => 'CreateDomain', 'DomainName' => domain_name)
      )
    end

    def delete_domain(domain_name)
      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge('Action' => 'DeleteDomain', 'DomainName' => domain_name)
      )
    end

    def domain_metadata(domain_name)
      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge('Action' => 'DomainMetadata', 'DomainName' => domain_name)
      )
    end

    def list_domains(next_token=nil, max_num=nil, &block)
      params = {}
      params['NextToken']          = next_token if next_token
      params['MaxNumberOfDomains'] = max_num    if max_num

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge('Action' => 'ListDomains').merge(params),
        ['DomainName']
      )
    end

    def pack_attrs(attrs, replaces=nil, prefix=nil)
      params = {}

      i = 0
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

    def unpack_attrs(attrs)
      ret = {}

      attrs.map do |val|
        name, value = val['Name'], val['Value']

        if ret.key? name
          ret[name] = [ret[name]] unless ret[name].is_a? Array
          ret[name] << value
        else
          ret[name] = value
        end
      end

      ret
    end

    def get_attributes(domain_name, item_name, attrs=[])
      params = {}

      i = 0
      attrs.each do |name|
        params["AttributeName.#{i}"] = name
        i += 1
      end

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge(
          'Action'     => 'GetAttributes',
          'DomainName' => domain_name,
          'ItemName'   => item_name
        ).merge(params)
      )
    end

    def put_attributes(domain_name, item_name, attrs={}, replaces=[])
      params = pack_attrs(attrs, replaces)

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge(
          'Action'     => 'PutAttributes',
          'DomainName' => domain_name,
          'ItemName'   => item_name
        ).merge(params)
      )
    end

    def batch_put_attributes(domain_name, items={}, replaces={})
      params = {}
      
      i = 0
      items.each do |key, attrs|
        params["Item.#{i}.ItemName"] = key
        params.merge!(pack_attrs(attrs, replaces[key], "Item.#{i}."))
        i += 1
      end

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge(
          'Action'     => 'BatchPutAttributes',
          'DomainName' => domain_name
        ).merge(params)
      )
    end

    def delete_attributes(domain_name, item_name, attrs={})
      params = pack_attrs(attrs)

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge(
          'Action'     => 'DeleteAttributes',
          'DomainName' => domain_name,
          'ItemName'   => item_name
        ).merge(params)
      )
    end

    def quote(val)
      if !REXP_NAME.match(val) || KEYWORDS.include?(val)
        "'#{val}'"
      else
        val
      end
    end

    def query_expr(expr, params)
      expr.gsub(/(\\)?(\?)/) do
        if $1
          "?"
        else
          "'#{params.shift.gsub(/(['])/, '\1\1')}'"
        end
      end
    end

    def select(expr, params=[], next_token=nil)
      params = {}
      params['NextToken'] = next_token if next_token

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge(
          'Action' => 'Select',
          'SelectExpression' => query_expr(expr, params)
        ).merge(params),
        ['Item', 'Attribute']
      )
    end
  end

  extend Adapter20090415
end
