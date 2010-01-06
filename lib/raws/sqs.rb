class RAWS::SQS
  autoload :Adapter, 'raws/sqs/adapter'
  autoload :Message, 'raws/sqs/message'
  autoload :Model,   'raws/sqs/model'

  class << self
    attr_writer :http

    def http
      @http ||= RAWS.http
    end

    def queue_url(queue_name)
      if URI.parse(queue_name).scheme
        queue_name
      else
        list(queue_name).each do |url|
          return url if URI.parse(url).path.split('/').last == queue_name
        end
      end
    end

    def create_queue(queue_name, default_visibility_timeout=nil)
      self.new\
        Adapter.create_queue(
          queue_name,
          default_visibility_timeout
        )['CreateQueueResponse']['CreateQueueResult']['QueueUrl']
    end

    def delete_queue(queue_name)
      Adapter.delete_queue queue_url(queue_name)
    end

    def queues(prefix=nil)
      (
        Adapter.list_queues(prefix)\
          ['ListQueuesResponse']['ListQueuesResult']['QueueUrl'] || []
      ).map do |val|
        self.new(val)
      end
    end
    alias :list :queues

    def [](queue_name)
      self.new(queue_url(queue_name))
    end

    def get_attrs(queue_name, *attrs)
      Adapter.get_queue_attributes(
        queue_url(queue_name),
        *attrs
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
    end

    def set_attrs(queue_name, attrs={})
      Adapter.set_queue_attributes queue_url(queue_name), attrs
    end

    def send(queue_name, msg)
      Adapter.send_message queue_url(queue_name), msg
    end

    def receive(queue_name, params={}, *attrs)
      Adapter.receive_message(
        queue_url(queue_name),
        params,
        *attrs
      )['ReceiveMessageResponse']['ReceiveMessageResult']['Message'] || []
    end

    def change_message_visibility(queue_name, receipt_handle, visibility_timeout)
      Adapter.change_message_visibility(
        queue_url(queue_name),
        receipt_handle,
        visibility_timeout
      )
    end

    def delete_message(queue_name, receipt_handle)
      Adapter.delete_message queue_url(queue_name), receipt_handle
    end

    def add_permission(queue_name, label, permission)
      Adapter.add_permission queue_url(queue_name), label, permission
    end

    def remove_permission(queue_name, label)
      Adapter.remove_permission queue_url(queue_name), label
    end
  end

  attr_reader :queue_url
  attr_reader :queue_name

  def initialize(queue_url)
    @queue_url  = queue_url
    @queue_name = URI.parse(@queue_url).path.split('/').last
  end

  def delete_queue
    self.class.delete_queue queue_url
  end

  def get_attrs(*attrs)
    self.class.get_attrs queue_url, *attrs
  end

  def set_attrs(attrs={})
    self.class.set_attrs queue_url, attrs
  end

  def send(msg)
    self.class.send queue_url, msg
  end

  def receive(params={}, *attrs)
    self.class.receive(queue_url, params, *attrs).map do |val|
      Message.new self, val
    end
  end

  def change_message_visibility(receipt_handle, visibility_timeout)
    self.class.change_message_visibility(
      queue_url,
      receipt_handle,
      visibility_timeout
    )
  end

  def delete_message(receipt_handle)
    self.class.delete_message queue_url, receipt_handle
  end

  def add_permission(label, permission)
    self.class.add_permission queue_url, label, permission
  end

  def remove_permission(label)
    self.class.remove_permission queue_url, label
  end
end
