class RAWS::SQS
  autoload :Adapter, 'raws/sqs/adapter'
  autoload :Message, 'raws/sqs/message'
  autoload :Model,   'raws/sqs/model'

  class << self
    attr_writer :http

    def http
      @http ||= RAWS.http
    end

    # Returns the queue URL for the +queue_name_or_url+ if exists the queue.
    def queue_url(queue_name_or_url)
      if URI.parse(queue_name_or_url).scheme
        queue_name_or_url
      else
        list(queue_name_or_url).map do |sqs|
          sqs.queue_url
        end.each do |url|
          return url if URI.parse(url).path.split('/').last == queue_name_or_url
        end
      end
    end

    # Creates a new queue and returns the instance of RAWS::SQS.
    def create_queue(queue_name, default_visibility_timeout=nil)
      self.new\
        Adapter.create_queue(
          queue_name,
          default_visibility_timeout
        )['CreateQueueResponse']['CreateQueueResult']['QueueUrl']
    end

    # Deletes the queue.
    def delete_queue(queue_name_or_url)
      Adapter.delete_queue queue_url(queue_name_or_url)
    end

    # Returns an array of RAWS::SQS objects.
    def queues(prefix=nil)
      (
        Adapter.list_queues(prefix)\
          ['ListQueuesResponse']['ListQueuesResult']['QueueUrl'] || []
      ).map do |val|
        self.new(val)
      end
    end
    alias :list :queues

    # Returns the instance of RAWS::SQS.
    def [](queue_name_or_url)
      self.new queue_url(queue_name_or_url)
    end

    # Returns the queue attributes.
    #
    # * +attrs+ -
    #   All,
    #   ApproximateNumberOfMessages,
    #   ApproximateNumberOfMessagesNotVisible,
    #   VisibilityTimeout,
    #   CreatedTimestamp,
    #   LastModifiedTimestamp,
    #   Policy
    def get_queue_attributes(queue_name_or_url, *attrs)
      Adapter.get_queue_attributes(
        queue_url(queue_name_or_url),
        *attrs
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
    end

    # Sets the queue attributes.
    #
    # * +attrs+ - {_AttributeName_ => _AttributeValue_}
    #   * AttributeName - VisibilityTimeout, Policy
    def set_queue_attributes(queue_name_or_url, attrs={})
      Adapter.set_queue_attributes queue_url(queue_name_or_url), attrs
    end

    # Sends a message to the queue.
    def send_message(queue_name_or_url, msg)
      Adapter.send_message queue_url(queue_name_or_url), msg
    end
    alias :send :send_message

    # Receives one or more messages form the queue.
    # Returns an array of message data.
    def receive_message(queue_name_or_url, params={}, *attrs)
      Adapter.receive_message(
        queue_url(queue_name_or_url),
        params,
        *attrs
      )['ReceiveMessageResponse']['ReceiveMessageResult']['Message'] || []
    end
    alias :receive :receive_message

    # Changes the message visibility timeout.
    def change_message_visibility(
      queue_name_or_url,
      receipt_handle,
      visibility_timeout
    )
      Adapter.change_message_visibility(
        queue_url(queue_name_or_url),
        receipt_handle,
        visibility_timeout
      )
    end

    # Deletes the message.
    def delete_message(queue_name, receipt_handle)
      Adapter.delete_message queue_url(queue_name), receipt_handle
    end

    # Adds the permissions.
    #
    # * +permissions+ - {_AWSAccountId_ => [_ActionName_, ...], ...}
    #   * +ActionName+ - *,
    #     SendMessage,
    #     ReceiveMessage,
    #     DeleteMessage,
    #     ChangeMessageVisibility,
    #     GetQueueAttributes
    def add_permission(queue_name, label, permissions)
      Adapter.add_permission queue_url(queue_name), label, permissions
    end

    # Removes the permission.
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

  # Delete the queue.
  def delete_queue
    self.class.delete_queue queue_url
  end

  # Returns the queue attributes.
  #
  # * +attrs+ -
  #   All,
  #   ApproximateNumberOfMessages,
  #   ApproximateNumberOfMessagesNotVisible,
  #   VisibilityTimeout,
  #   CreatedTimestamp,
  #   LastModifiedTimestamp,
  #   Policy
  def get_queue_attributes(*attrs)
    self.class.get_queue_attributes queue_url, *attrs
  end

  # Sets the queue attributes.
  #
  # * +attrs+ - {_AttributeName_ => _AttributeValue_}
  #   * AttributeName - VisibilityTimeout, Policy
  def set_queue_attributes(attrs={})
    self.class.set_queue_attributes queue_url, attrs
  end

  # Sends the message to the queue.
  def send_message(msg)
    self.class.send_message queue_url, msg
  end
  alias :send :send_message

  # Receives the messages form the queue.
  # Returns an array of RAWS::SQS::Message objects.
  def receive_message(params={}, *attrs)
    self.class.receive_message(queue_url, params, *attrs).map do |val|
      Message.new self, val
    end
  end
  alias :receive :receive_message

  # Changes the message visivility timeout.
  def change_message_visibility(receipt_handle, visibility_timeout)
    self.class.change_message_visibility(
      queue_url,
      receipt_handle,
      visibility_timeout
    )
  end

  # Deletes the message.
  def delete_message(receipt_handle)
    self.class.delete_message queue_url, receipt_handle
  end

  # Adds the permissions.
  #
  # * +permissions+ - {_AWSAccountId_ => [_ActionName_, ...], ...}
  #   * +ActionName+ - *,
  #     SendMessage,
  #     ReceiveMessage,
  #     DeleteMessage,
  #     ChangeMessageVisibility,
  #     GetQueueAttributes
  def add_permission(label, permission)
    self.class.add_permission queue_url, label, permission
  end

  # Removes the permission.
  def remove_permission(label)
    self.class.remove_permission queue_url, label
  end
end
