class JAWS::SDB
  autoload :Adapter, 'jaws/sdb/adapter'
  autoload :Select,  'jaws/sdb/select'

  def self.create_domain(name)
    Adapter.create_domain(name)
  end

  def self.delete_domain(name)
    Adapter.delete_domain(name)
  end

  def self.list_domains(next_token=nil, max_num=nil)
    Adapter.list_domains(next_token, max_num)
  end

  def self.select(expr, next_token=nil, &block)
    begin
      data = Adapter.select(expr, next_token)['SelectResponse']['SelectResult']

      data['Item'].each do |val|
        block.call(val)
      end
    end while next_token = data['NextToken']
  end

  def self.each(&block)
    next_token = nil
    begin
      data = list_domains(next_token)['ListDomainsResponse']['ListDomainsResult']

      data['DomainName'].each do |val|
        block.call(self.new(val))
      end
    end while next_token = data['NextToken']
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
