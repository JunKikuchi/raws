class JAWS::SQS
  autoload :Adapter, 'jaws/sqs/adapter'

  class << self
    def create(queue_name, timeout=nil)
      Adapter.create_queue(queue_name, timeout)
    end

    def delete(queue_name)
      Adapter.delete_queue(queue_name)
    end

    def attrs(queue_name)
      Adapter.get_queue_attributes(queue_name)
    end

    def list(next_token=nil, max_num=nil)
      Adapter.list_queues(next_token, max_num)
    end
  end
end
