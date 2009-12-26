require 'uuidtools'

module RAWS::SDB::Model
  class Select < RAWS::SDB::Select
    def initialize(model)
      super()
      @model = model
    end

    def attr_filter(val)
      @model.new(val.last, val.first, true)
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

    def select(&block)
      Select.new(self).from(domain_name, &block)
    end
    alias :all :select

    def find(id)
      if attrs = RAWS::SDB[domain_name].get(id)
        self.new(attrs, id, true)
      end
    end

    def batch_put(items={}, replaces={})
      RAWS::SDB[domain_name].batch_put(items, replaces)
    end

    def create_id
      [
        UUIDTools::UUID.random_create.raw
      ].pack('m').sub(/==\n$/, '').tr('+/', '-_')
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
    attr_accessor :id
    attr_reader :values

    def initialize(values={}, id=nil, exists=false)
      @id, @values, @exists = id, values, exists
      after_initialize
    end

    def create_id
      self.class.create_id
    end

    def exists?
      @exists
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
      @exists = false
      after_delete
    end

    def save
      before_save
      if exists?
        before_update
        RAWS::SDB[self.class.domain_name].put(id, values, *values.keys)
        after_update
      else
        before_insert
        @id ||= create_id
        RAWS::SDB[self.class.domain_name].put(id, values, *values.keys)
        @exists = true
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
