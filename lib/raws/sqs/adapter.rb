class RAWS::SQS::Adapter
  module Adapter20090201
    URI = 'https://queue.amazonaws.com/'
    PARAMS = {'Version' => '2009-02-01'}

    def create_queue(queue_name, timeout=nil)
      params = {
        'Action'    => 'CreateQueue',
        'QueueName' => queue_name
      }
      params['DefaultVisibilityTimeout'] = timeout if timeout

      RAWS.fetch('GET', URI, PARAMS.merge(params))
    end

    def delete_queue(queue_url)
      params = {'Action' => 'DeleteQueue'}

      RAWS.fetch('GET', queue_url, PARAMS.merge(params))
    end

    def list_queues(prefix=nil)
      params = {'Action' => 'ListQueues'}
      params['QueueNamePrefix'] = prefix if prefix

      RAWS.fetch('GET', URI, PARAMS.merge(params), 'QueueUrl')
    end

    def pack_attrs(attrs)
      params = {}

      if(attrs.size == 1)
        params["AttributeName"] = attrs.first
      else
        i = 1
        attrs.each do |val|
          params["AttributeName.#{i}"] = val
          i += 1
        end
      end

      params
    end

    def get_queue_attributes(queue_url, *attrs)
      params = {'Action' => 'GetQueueAttributes'}
      if attrs.empty?
        params.merge!(pack_attrs(['All']))
      else
        params.merge!(pack_attrs(attrs))
      end

      RAWS.fetch(
        'GET',
        queue_url,
        PARAMS.merge(params),
        :multiple => %w'Attribute',
        :unpack   => %w'Attribute'
      )
    end

    def set_queue_attributes(queue_url, attrs={})
      params = {'Action' => 'SetQueueAttributes'}
      params.merge!(RAWS.pack_attrs(attrs))

      RAWS.fetch('GET', queue_url, PARAMS.merge(params))
    end

    def send_message(queue_url, msg)
      params = {
        'Action'      => 'SendMessage',
        'MessageBody' => msg
      }

      RAWS.fetch('GET', queue_url, PARAMS.merge(params))
    end

    def receive_message(queue_url, num_msgs=nil, timeout=nil, *attrs)
      params = {'Action' => 'ReceiveMessage'}
      params['MaxNumberOfMessages'] = num_msgs if num_msgs
      params['VisibilityTimeout']   = timeout  if timeout
      params.merge!(pack_attrs(attrs))

      RAWS.fetch(
        'GET',
        queue_url,
        PARAMS.merge(params),
        :multiple => %w'Message Attribute',
        :unpack   => %w'Attribute'
      )
    end

    def delete_message(queue_url, receipt_handle)
      params = {
        'Action'        => 'DeleteMessage',
        'ReceiptHandle' => receipt_handle
      }

      RAWS.fetch('GET', queue_url, PARAMS.merge(params))
    end
  end

  extend Adapter20090201
end
