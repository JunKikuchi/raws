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
      queue.send(model.encode)
    end

    def receive
      queue.receive.map do |message|
        self.new(message)
      end
    end
  end

  module InstanceMethods
    attr_reader :message

    def initialize(message=nil)
      @message = message
      decode(message)
    end

    def encode
      ''
    end

    def decode(message)
    end

    def send
      self.class.send(self)
    end

    def delete
      @message && @message.delete
    end
  end

  def self.included(mod)
    mod.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end
end
