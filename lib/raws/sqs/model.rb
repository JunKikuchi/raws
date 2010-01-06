require 'forwardable'

module RAWS::SQS::Model
  module ClassMethods
    extend Forwardable
    def_delegators :queue,
      :delete_queue,
      :get_queue_attributes,
      :set_queue_attributes,
      :send_message,
      :send,
      :receive_message,
      :receive,
      :add_permission,
      :remove_permission

    attr_accessor :queue_name

    def queue
      RAWS::SQS[self.queue_name]
    end

    def create_queue
      RAWS::SQS.create_queue(self.queue_name)
    end
  end

  def self.included(mod)
    mod.class_eval do
      extend ClassMethods
    end
  end
end
