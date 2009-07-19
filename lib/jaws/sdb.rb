class JAWS::SDB
  autoload :Adapter, 'jaws/sdb/adapter'
  autoload :Select,  'jaws/sdb/select'

  def self.create_domain(name)
    Adapter.create_domain(name)
  end

  def self.delete_domain(name)
    Adapter.delete_domain(name)
  end

  def self.list_domains(params={})
    Adapter.list_domains(params)
  end

  def self.select(exp, params={}, &block)
    params = {'NextToken' => nil}

    begin
      data = Adapter.select(exp, params)['SelectResponse']['SelectResult']

      data['Item'].each do |val|
        block.call(val)
      end

      params['NextToken'] = data['NextToken']
    end while params['NextToken']
  end

  def self.each(&block)
    params = {'NextToken' => nil}

    begin
      data = list_domains(params)['ListDomainsResponse']['ListDomainsResult']

      data['DomainName'].each do |val|
        block.call(self.new(val))
      end

      params['NextToken'] = data['NextToken']
    end while params['NextToken']
  end

  def self.[](name)
    self.new(name)
  end

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def create_domain
    self.class.create_domain(name)
  end

  def delete_domain
    self.class.delete_domain(name)
  end

  def select(output_list='*')
    Select.new.columns(output_list).from(name)
  end
end
