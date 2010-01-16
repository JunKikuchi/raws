require 'forwardable'
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
    extend Forwardable
    def_delegators :domain,
      :create_domain,
      :delete_domain,
      :domain_metadata,
      :metadata,
      :get_attributes,
      :get,
      :put_attributes,
      :put,
      :batch_put_attributes,
      :batch_put,
      :delete_attributes,
      :delete

    attr_accessor :domain_name

    def domain
      RAWS::SDB[domain_name]
    end

    def select(&block)
      Select.new(self).from(domain_name, &block)
    end
    alias :all :select

    def find(id)
      if attrs = get_attribute(id)
        self.new(attrs, id, true)
      end
    end

    def create_id
      [
        UUIDTools::UUID.random_create.raw
      ].pack('m').sub(/==\n$/, '').tr('+/', '-_')
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
      self.class.delete_attributes(id) if id
      @exists = false
      after_delete
    end

    def save
      before_save
      if exists?
        before_update
        self.class.put_attributes(id, values, *values.keys)
        after_update
      else
        before_insert
        @id ||= create_id
        self.class.put_attributes(id, values, *values.keys)
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

    def method_missing(_name, *args)
      name = _name.to_s
      if md = /(.+)=$/.match(name)
        self[md[1]] = args.unshift
      elsif values.key?(name)
        self[name]
      end
    end
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
end
