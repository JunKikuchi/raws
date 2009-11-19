class RAWS::SQS
  autoload :Adapter, 'raws/sqs/adapter'

  class << self
    include Enumerable

    attr_writer :http

    def http
      @http ||= RAWS.http
    end

    def queue_url(queue_name)
      data = Adapter.list_queues(
        queue_name
      )['ListQueuesResponse']['ListQueuesResult']

      data['QueueUrl'].each do |url|
        _queue_name = URI.parse(url).path.split('/').last
        if _queue_name == queue_name
          return url
        end
      end unless data.empty?
    end

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
      (
        Adapter.list_queues(
          prefix
        )['ListQueuesResponse']['ListQueuesResult']['QueueUrl'] || []
      ).map do |val|
        self.new(val)
      end
    end

    def each(&block)
      list.each(&block)
    end

    def [](queue_name)
      if url = queue_url(queue_name)
        self.new(queue_url(queue_name))
      end
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

    def send(queue_url, msg)
      Adapter.send_message(queue_url, msg)
    end

    def receive(queue_url, params={}, *attrs)
      Adapter.receive_message(
        queue_url,
        params[:limit],
        params[:timeout],
        *attrs
      )['ReceiveMessageResponse']['ReceiveMessageResult']['Message'] || []
    end

    def change_message_visibility(queue_url, handle, timeout)
      Adapter.change_message_visibility(queue_url, handle, timeout)
    end

    def delete_message(queue_url, handle)
      Adapter.delete_message(queue_url, handle)
    end

    def add_permission(queue_url, label, permission)
      Adapter.add_permission(queue_url, label, permission)
    end

    def remove_permission(queue_url, label)
      Adapter.remove_permission(queue_url, label)
    end
  end

  class Message
    attr_reader :queue
    attr_reader :data

    def initialize(queue, data)
      @queue, @data = queue, data
    end

    def body
      data['Body']
    end

    def visibility=(timeout)
      queue.change_message_visibility data['ReceiptHandle'], timeout
    end

    def delete
      queue.delete_message data['ReceiptHandle']
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

  def send(msg)
    self.class.send(queue_url, msg)
  end

  def receive(params={}, *attrs)
    self.class.receive(queue_url, params, *attrs).map do |val|
      Message.new(self, val)
    end
  end

  def change_message_visibility(handle, timeout)
    self.class.change_message_visibility(queue_url, handle, timeout)
  end

  def delete_message(handle)
    self.class.delete_message(queue_url, handle)
  end

  def add_permission(label, permission)
    self.class.add_permission(queue_url, label, permission)
  end

  def remove_permission(label)
    self.class.remove_permission(queue_url, label)
  end

  def <=>(a)
    queue_name <=> a.queue_name
  end
end
