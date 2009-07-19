class JAWS::SDB::Adapter
  module Adapter20090415
    URI = 'https://sdb.amazonaws.com/'
    PARAMS = {'Version' => '2009-04-15'}

    def create_domain(name)
      JAWS.send(
        'GET',
        URI,
        PARAMS.merge('Action' => 'CreateDomain', 'DomainName' => name)
      )
    end

    def delete_domain(name)
      JAWS.send(
        'GET',
        URI,
        PARAMS.merge('Action' => 'DeleteDomain', 'DomainName' => name)
      )
    end

    def list_domains(params={}, &block)
      if params.key? 'NextToken' && params['NextToken'].nil?
        params.delete 'NextToken'
      end

      data = JAWS.send(
        'GET',
        URI,
        PARAMS.merge('Action' => 'ListDomains').merge(params)
      )

      name = data['ListDomainsResponse']['ListDomainsResult']
      unless name['DomainName'].is_a? Array
        name['DomainName'] = [name['DomainName']]
      end

      data
    end

    def select(exp, params={})
      if params.key? 'NextToken' && params['NextToken'].nil?
        params.delete 'NextToken'
      end

      JAWS.send(
        'GET',
        URI,
        PARAMS.merge(
          'Action' => 'Select',
          'SelectExpression' => exp
        ).merge(params)
      )
    end
  end

  extend Adapter20090415
end
