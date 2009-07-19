class JAWS::SDB
  class Adapter
    module Adapter20090415
      URI = 'https://sdb.amazonaws.com/'
      PARAMS = {'Version' => '2009-04-15'}

      def create_domain(name)
      end

      def delete_domain(name)
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
    end

    extend Adapter20090415
  end

  def self.each(&block)
    params = {'NextToken' => nil}
    begin
      data = Adapter.list_domains(
        params
      )['ListDomainsResponse']['ListDomainsResult']

      data['DomainName'].each do |val|
        block.call(val)
      end

      params['NextToken'] = data['NextToken']
    end while params['NextToken']
  end
end
