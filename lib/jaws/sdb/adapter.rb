class JAWS::SDB::Adapter
  module Adapter20090415
    URI = 'https://sdb.amazonaws.com/'
    PARAMS = {'Version' => '2009-04-15'}

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

    def pack_attrs(attrs, replaces=[])
      params = {}

      i = 0
      attrs.each do |key, val|
        params["Attribute.#{i}.Replace"] = 'true' if replaces.include?(key)
        if val.is_a? Array
          val.each do |v|
            params["Attribute.#{i}.Name"]  = key
            params["Attribute.#{i}.Value"] = v
            i += 1
          end
        else
          params["Attribute.#{i}.Name"]  = key
          params["Attribute.#{i}.Value"] = val
          i += 1
        end
      end

      params
    end
    private :pack_attrs

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

    def select(exp, next_token=nil)
      params = {}
      params['NextToken'] = next_token if next_token

      JAWS.fetch(
        'GET',
        URI,
        PARAMS.merge(
          'Action' => 'Select',
          'SelectExpression' => exp
        ).merge(params),
        ['Item', 'Attribute']
      )
    end
  end

  extend Adapter20090415
end
