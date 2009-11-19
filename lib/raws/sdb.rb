class RAWS::SDB
  autoload :Adapter, 'raws/sdb/adapter'
  autoload :Select,  'raws/sdb/select'
  autoload :Model,   'raws/sdb/model'

  class << self
    include Enumerable

    attr_writer :http

    def http
      @http ||= RAWS.http
    end

    def create_domain(domain_name)
      Adapter.create_domain(domain_name)
    end

    def delete_domain(domain_name)
      Adapter.delete_domain(domain_name)
    end

    def metadata(domain_name)
      Adapter.domain_metadata(
        domain_name
      )['DomainMetadataResponse']['DomainMetadataResult']
    end

    def list(next_token=nil, max_num=nil)
      Adapter.list_domains(
        next_token,
        max_num
      )['ListDomainsResponse']['ListDomainsResult']
    end

    def each(&block)
      next_token = nil
      begin
        data = list(next_token)
        if domain = data['DomainName']
          domain.each do |val|
            block.call(self.new(val))
          end
        end
      end while next_token = data['NextToken']
    end

    def [](domain_name)
      @cache ||= {}
      @cache[domain_name] ||= self.new(domain_name)
    end

    def select(expr, params=[], next_token=nil, &block)
      begin
        data = Adapter.select(
          expr,
          params,
          next_token
        )['SelectResponse']['SelectResult']

        data['Item'].each do |val|
          block.call([val['Name'], val['Attribute']])
        end if data.key? 'Item'
      end while next_token = data['NextToken']
    end
    alias :all :select

    def get(domain_name, item_name, *attrs)
      Adapter.get_attributes(
        domain_name,
        item_name,
        *attrs
      )['GetAttributesResponse']['GetAttributesResult']['Attribute']
    end

    def put(domain_name, item_name, attrs={}, *replaces)
      Adapter.put_attributes(domain_name, item_name, attrs, *replaces)
    end

    def batch_put(domain_name, items={}, replaces={})
      Adapter.batch_put_attributes(domain_name, items, replaces)
    end

    def delete(domain_name, item_name, attrs={})
      Adapter.delete_attributes(domain_name, item_name, attrs)
    end
  end

  attr_reader :domain_name

  def initialize(domain_name)
    @domain_name = domain_name
  end

  def create_domain
    self.class.create_domain(domain_name)
  end

  def delete_domain
    self.class.delete_domain(domain_name)
  end

  def metadata
    self.class.metadata(domain_name)
  end

  def select(output_list='*', &block)
    Select.new.columns(output_list).from(domain_name, &block)
  end
  alias :all :select

  def get(item_name, *attrs)
    self.class.get(domain_name, item_name, *attrs)
  end

  def put(item_name, attrs={}, *replaces)
    self.class.put(domain_name, item_name, attrs, *replaces)
  end

  def batch_put(items={}, replaces={})
    self.class.batch_put(domain_name, items, replaces)
  end

  def delete(item_name, attrs={})
    self.class.delete(domain_name, item_name, attrs)
  end

  def <=>(a)
    domain_name <=> a.domain_name
  end
end
