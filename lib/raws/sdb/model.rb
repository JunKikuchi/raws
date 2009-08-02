require 'uuidtools'

module RAWS::SDB::Model
  class Select < RAWS::SDB::Select
    def initialize(model)
      super()
      @model = model
    end

    def attr_filter(val)
      @model.new(val.last, val.first)
    end
  end

  module ClassMethods
    attr_accessor :domain_name

    def create_domain
      RAWS::SDB[domain_name].create_domain
    end

    def delete_domain
      RAWS::SDB[domain_name].delete_domain
    end

    def select
      Select.new(self).from(domain_name)
    end

    def generate_id
      UUIDTools::UUID.random_create
    end
  end
  
  module InstanceMethods
    attr_reader :id, :values

    def initialize(values={}, id=nil)
      @id, @values = id, values
    end

    def [](key)
      values[key]
    end

    def []=(key, val)
      values[key] = val
    end

    def delete
      RAWS::SDB[self.class.domain_name].delete(id) if id
    end

    def save
      RAWS::SDB[self.class.domain_name].put(
        id || self.class.generate_id,
        values
      )
    end
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
end
