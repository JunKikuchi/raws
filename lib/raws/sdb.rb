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

    # Creates a new domain and returns the instance of RAWS:SDB.
    def create_domain(domain_name)
      Adapter.create_domain(domain_name)
      self[domain_name]
    end

    # Deletes the domain.
    def delete_domain(domain_name)
      Adapter.delete_domain(domain_name)
    end

    # Returns the domain metadata.
    def domain_metadata(domain_name)
      Adapter.domain_metadata(domain_name)\
        ['DomainMetadataResponse']['DomainMetadataResult']
    end

    def list_domains(params={})
      doc = Adapter.list_domains(params)\
        ['ListDomainsResponse']['ListDomainsResult']

      {
        'Domains' => (doc ? doc['DomainName'] : []).map do |v| self.new(v) end,
        'NextToken' => doc && doc['NextToken']
      }
    end

    def each(params={}, &block)
      next_token = nil
      begin
        data = list_domains(params.merge('NextToken' => next_token))
        data['Domains'].each(&block)
      end while next_token = data['NextToken']
    end

    def domains(&block)
      if block_given?
        each(&block)
      else
        map
      end
    end

    # Returns the instance of RAWS::SDB.
    def [](domain_name)
      self.new domain_name
    end

    def select(expr, params=[], &block)
      next_token = nil
      begin
        ret = Adapter.select(expr, params, next_token)\
          ['SelectResponse']['SelectResult']
        ret['Item'].each do |val|
          block.call [val['Name'], val['Attribute']]
        end if ret.key? 'Item'
      end while next_token = ret['NextToken']
    end
    alias :all :select

    def get_attributes(domain_name, item_name, *attrs)
      doc = Adapter.get_attributes(domain_name, item_name, *attrs)\
        ['GetAttributesResponse']['GetAttributesResult']
      doc && doc['Attribute']
    end
    alias :get :get_attributes

    def put_attributes(domain_name, item_name, attrs={}, *replaces)
      Adapter.put_attributes domain_name, item_name, attrs, *replaces
    end
    alias :put :put_attributes

    def batch_put_attributes(domain_name, items={}, replaces={})
      Adapter.batch_put_attributes domain_name, items, replaces
    end
    alias :batch_put :batch_put_attributes

    def delete_attributes(domain_name, item_name, attrs={})
      Adapter.delete_attributes domain_name, item_name, attrs
    end
    alias :delete :delete_attributes
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

  def domain_metadata
    self.class.domain_metadata(domain_name)
  end
  alias :metadata :domain_metadata

  def select(output_list='*', &block)
    Select.new.columns(output_list).from(domain_name, &block)
  end
  alias :all :select

  def get_attributes(item_name, *attrs)
    self.class.get_attributes domain_name, item_name, *attrs
  end
  alias :get :get_attributes

  def put_attributes(item_name, attrs, *replaces)
    self.class.put_attributes domain_name, item_name, attrs, *replaces
  end
  alias :put :put_attributes

  def batch_put_attributes(items, replaces={})
    self.class.batch_put_attributes domain_name, items, replaces
  end
  alias :batch_put :batch_put_attributes

  def delete_attributes(item_name, attrs={})
    self.class.delete_attributes domain_name, item_name, attrs
  end
  alias :delete :delete_attributes

  def <=>(a)
    domain_name <=> a.domain_name
  end
end
