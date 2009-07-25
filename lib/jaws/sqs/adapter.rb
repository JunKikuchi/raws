class JAWS::SQS::Adapter
  module Adapter20090201
    URI = 'https://queue.amazonaws.com/'
    PARAMS = {'Version' => '2009-02-01'}

    def create_queue(queue_name, timeout=nil)
      params = {
        'Action'    => 'CreateQueue',
        'QueueName' => queue_name
      }
      params['DefaultVisibilityTimeout'] = timeout if timeout

      JAWS.fetch('GET', URI, PARAMS.merge(params))
    end

    def delete_queue(queue_url)
      params = {'Action' => 'DeleteQueue'}

      JAWS.fetch('GET', queue_url, PARAMS.merge(params))
    end

    def list_queues(prefix=nil)
      params = {'Action' => 'ListQueues'}
      params['QueueNamePrefix'] = prefix if prefix

      JAWS.fetch('GET', URI, PARAMS.merge(params))
    end

    def pack_attrs(*attrs)
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
        params.merge!(pack_attrs('All'))
      else
        params.merge!(pack_attrs(*attrs))
      end

      JAWS.fetch('GET', queue_url, PARAMS.merge(params), 'Attribute')
    end

    def set_queue_attributes(queue_url, attrs={})
      params = {'Action' => 'SetQueueAttributes'}
      params.merge!(JAWS.pack_attrs(attrs))

      p params

      JAWS.fetch('GET', queue_url, PARAMS.merge(params))
    end
  end

  extend Adapter20090201
end
