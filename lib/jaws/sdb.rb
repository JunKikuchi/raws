class JAWS::SDB
  autoload :Adapter, 'jaws/sdb/adapter'
  autoload :Select,  'jaws/sdb/select'

  class << self
    def create(domain_name)
      Adapter.create_domain(domain_name)
    end

    def delete(domain_name)
      Adapter.delete_domain(domain_name)
    end

    def metadata(domain_name)
      Adapter.domain_metadata(domain_name)
    end

    def list(next_token=nil, max_num=nil)
      Adapter.list_domains(next_token, max_num)
    end

    def select(expr, next_token=nil, &block)
      begin
        data = Adapter.select(
          expr,
          next_token
        )['SelectResponse']['SelectResult']

        data['Item'].each do |val|
          block.call([val['Name'], Adapter.unpack_attrs(val['Attribute'])])
        end if data.key? 'Item'
      end while next_token = data['NextToken']
    end

    def get(domain_name, item_name, attrs=[])
      data = Adapter.get_attributes(
        domain_name,
        item_name,
        attrs
      )['GetAttributesResponse']['GetAttributesResult']
      Adapter.unpack_attrs(data['Attribute'])
    end

    def put(domain_name, item_name, attrs={}, replaces=[])
      Adapter.put_attributes(domain_name, item_name, attrs, replaces)
    end

    def batch_put(domain_name, items={}, replaces={})
      Adapter.batch_put_attributes(domain_name, items, replaces)
    end

    def each(&block)
      next_token = nil
      begin
        data = list(next_token)['ListDomainsResponse']['ListDomainsResult']

        data['DomainName'].each do |val|
          block.call(self.new(val))
        end
      end while next_token = data['NextToken']
    end

    def [](domain_name)
      @cache ||= {}
      @cache[domain_name] ||= self.new(domain_name)
    end
  end

  attr_reader :domain_name

  def initialize(domain_name)
    @domain_name = domain_name
  end

  def create
    self.class.create(domain_name)
  end

  def delete
    self.class.delete(domain_name)
  end

  def metadata
    self.class.metadata(domain_name)
  end

  def get(item_name, attrs=[])
    self.class.get(domain_name, item_name, attrs)
  end

  def put(item_name, attrs={}, replaces=[])
    self.class.put(domain_name, item_name, attrs, replaces)
  end

  def batch_puth(items={}, replaces={})
    self.class.batch_put(domain_name, items, replaces)
  end

  def select(output_list='*')
    Select.new.columns(output_list).from(domain_name)
  end
end
