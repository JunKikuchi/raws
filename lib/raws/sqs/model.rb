module RAWS::SQS::Model
  module ClassMethods
    attr_accessor :queue_name

    def create_queue
      RAWS::SQS.create_queue(self.queue_name)
    end

    def delete_queue(force=nil)
      RAWS::SQS.delete_queue(self.queue_name)
    end

    def queue
      RAWS::SQS[self.queue_name]
    end

    def send(model)
      queue.send model
    end

    def receive(params={}, *attrs)
      queue.receive params, *attrs
    end
  end

  module InstanceMethods
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
end
