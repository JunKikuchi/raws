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

    def sdb_reader(*names)
      names.each do |name|
        module_eval %Q{
          def #{name}
            self['#{name}']
          end
        }
      end
    end

    def sdb_writer(*names)
      names.each do |name|
        module_eval %Q{
          def #{name}=(val)
            self['#{name}'] = val
          end
        }
      end
    end

    def sdb_accessor(*names)
      sdb_reader(*names)
      sdb_writer(*names)
    end
  end
  
  module InstanceMethods
    attr_reader :id, :values

    def initialize(values={}, id=nil)
      @id, @values = id, values
      after_initialize
    end

    def [](key)
      values[key]
    end

    def []=(key, val)
      values[key] = val
    end

    def delete
      before_delete
      RAWS::SDB[self.class.domain_name].delete(id) if id
      after_delete
    end

    def save
      before_save
      if id
        before_update
        RAWS::SDB[self.class.domain_name].put(id, values)
        after_update
      else
        before_insert
        @id = self.class.generate_id
        RAWS::SDB[self.class.domain_name].put(id, values)
        after_insert
      end
      after_save
    end

    def after_initialize; end
    def before_delete; end
    def after_delete; end
    def before_save; end
    def after_save; end
    def before_update; end
    def after_update; end
    def before_insert; end
    def after_insert; end
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
end
