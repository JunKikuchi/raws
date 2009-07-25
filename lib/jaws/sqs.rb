class JAWS::SQS
  autoload :Adapter, 'jaws/sqs/adapter'

  class << self
    def create_queue(queue_name, timeout=nil)
      self.new(
        Adapter.create_queue(
          queue_name,
          timeout
        )['CreateQueueResponse']['CreateQueueResult']['QueueUrl']
      )
    end

    def delete_queue(queue_url)
      Adapter.delete_queue(queue_url)
    end

    def list(prefix=nil)
      Adapter.list_queues(
        prefix
      )['ListQueuesResponse']['ListQueuesResult']['QueueUrl'].map do |val|
        self.new(val)
      end
    end

    def each(&block)
      list.each(&block)
    end

    def get_attrs(queue_url, *attrs)
      Adapter.get_queue_attributes(
        queue_url,
        *attrs
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
    end

    def set_attrs(queue_url, attrs={})
      Adapter.set_queue_attributes(queue_url, attrs)
    end
  end

  attr_reader :queue_url
  attr_reader :queue_name

  def initialize(queue_url)
    @queue_url  = queue_url
    @queue_name = URI.parse(@queue_url).path.split('/').last
  end

  def delete_queue
    self.class.delete_queue(queue_url)
  end

  def get_attrs(*attrs)
    self.class.get_attrs(queue_url, *attrs)
  end

  def set_attrs(attrs={})
    self.class.set_attrs(queue_url, attrs)
  end
end
