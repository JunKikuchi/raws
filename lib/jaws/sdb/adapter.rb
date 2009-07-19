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

    def list_domains(next_token=nil, max_num=nil, &block)
      params = {}
      params['NextToken']          = next_token if next_token
      params['MaxNumberOfDomains'] = max_num    if max_num

      JAWS.send(
        'GET',
        URI,
        PARAMS.merge('Action' => 'ListDomains').merge(params)
      )
    end

    def select(exp, next_token=nil)
      params = {}
      params['NextToken'] = next_token if next_token

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
