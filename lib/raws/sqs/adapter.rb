class RAWS::SQS::Adapter
  module Adapter20090201
    URI = 'https://queue.amazonaws.com/'
    PARAMS = {'Version' => '2009-02-01'}

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

    def pack_nv_attrs(attrs, replaces=nil, prefix=nil)
      params = {}

      i = 1
      attrs.each do |key, val|
        if !replaces.nil? && replaces.include?(key)
          params["#{prefix}Attribute.#{i}.Replace"] = 'true'
        end

        if val.is_a? Array
          val.each do |v|
            params["#{prefix}Attribute.#{i}.Name"]  = key
            params["#{prefix}Attribute.#{i}.Value"] = v
            i += 1
          end
        else
          params["#{prefix}Attribute.#{i}.Name"]  = key
          params["#{prefix}Attribute.#{i}.Value"] = val
          i += 1
        end
      end

      params
    end

    def sign(method, base_uri, params)
      path = {
        'AWSAccessKeyId'   => RAWS.aws_access_key_id,
        'SignatureMethod'  => 'HmacSHA256',
        'SignatureVersion' => '2',
        'Timestamp'        => Time.now.utc.iso8601
      }.merge(params).map do |key, val|
        "#{RAWS.escape(key)}=#{RAWS.escape(val)}"
      end.sort.join('&')

      uri = ::URI.parse(base_uri)
      "#{path}&Signature=" << RAWS.escape(
        [
          ::OpenSSL::HMAC.digest(
            ::OpenSSL::Digest::SHA256.new,
            RAWS.aws_secret_access_key,
            "#{method.upcase}\n#{uri.host.downcase}\n#{uri.path}\n#{path}"
          )
        ].pack('m').strip
      )
    end

    def connect(method, base_uri, params, parser={})
      doc = nil

      RAWS.http.connect(
        "#{base_uri}?#{sign(method, base_uri, params)}"
      ) do |request|
        request.method = method
        response = request.send
        doc = response.parse(parser)
        response
      end

      doc
    end

    def create_queue(queue_name, timeout=nil)
      params = {
        'Action'    => 'CreateQueue',
        'QueueName' => queue_name
      }
      params['DefaultVisibilityTimeout'] = timeout if timeout

      connect('GET', URI, PARAMS.merge(params))
    end

    def delete_queue(queue_url)
      params = {'Action' => 'DeleteQueue'}

      connect('GET', queue_url, PARAMS.merge(params))
    end

    def list_queues(prefix=nil)
      params = {'Action' => 'ListQueues'}
      params['QueueNamePrefix'] = prefix if prefix

      connect('GET', URI, PARAMS.merge(params), 'QueueUrl')
    end

    def get_queue_attributes(queue_url, *attrs)
      params = {'Action' => 'GetQueueAttributes'}
      if attrs.empty?
        params.merge!(pack_attrs(['All']))
      else
        params.merge!(pack_attrs(attrs))
      end

      connect(
        'GET',
        queue_url,
        PARAMS.merge(params),
        :multiple => %w'Attribute',
        :unpack   => %w'Attribute'
      )
    end

    def set_queue_attributes(queue_url, attrs={})
      params = {'Action' => 'SetQueueAttributes'}
      params.merge!(pack_nv_attrs(attrs))

      connect('GET', queue_url, PARAMS.merge(params))
    end

    def send_message(queue_url, msg)
      params = {
        'Action'      => 'SendMessage',
        'MessageBody' => msg
      }

      connect('GET', queue_url, PARAMS.merge(params))
    end

    def receive_message(queue_url, limit=nil, timeout=nil, *attrs)
      params = {'Action' => 'ReceiveMessage'}
      params['MaxNumberOfMessages'] = limit   if limit
      params['VisibilityTimeout']   = timeout if timeout
      params.merge!(pack_attrs(attrs))

      connect(
        'GET',
        queue_url,
        PARAMS.merge(params),
        :multiple => %w'Message Attribute',
        :unpack   => %w'Attribute'
      )
    end

    def change_message_visibility(queue_url, receipt_handle, timeout)
      params = {
        'Action'            => 'ChangeMessageVisibility',
        'ReceiptHandle'     => receipt_handle,
        'VisibilityTimeout' => timeout
      }

      connect('GET', queue_url, PARAMS.merge(params))
    end

    def delete_message(queue_url, receipt_handle)
      params = {
        'Action'        => 'DeleteMessage',
        'ReceiptHandle' => receipt_handle
      }

      connect('GET', queue_url, PARAMS.merge(params))
    end

    def pack_permission(params)
      ret = {}

      i = 1
      params.each do |id, permissions|
        permissions.each do |permission|
          ret["AWSAccountId.#{i}"] = id
          ret["ActionName.#{i}"]   = permission
          i += 1
        end
      end

      ret
    end

    def add_permission(queue_url, label, permission)
      params = {
        'Action' => 'AddPermission',
        'Label'  => label
      }
      params.merge!(pack_permission(permission))

      connect('GET', queue_url, PARAMS.merge(params))
    end

    def remove_permission(queue_url, label)
      params = {
        'Action' => 'RemovePermission',
        'Label'  => label
      }

      connect('GET', queue_url, PARAMS.merge(params))
    end
  end

  extend Adapter20090201
end
