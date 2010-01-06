class RAWS::SQS::Message
  attr_reader :queue
  attr_reader :data

  def initialize(queue, data)
    @queue, @data = queue, data
  end

  def message_id
    data['MessageId']
  end
  alias :id :message_id

  def receipt_handle
    data['ReceiptHandle']
  end

  def md5_of_body
    data['MD5OfBody']
  end

  def attributes
    data['Attribute']
  end
  alias :attrs :attributes

  def body
    data['Body']
  end

  def change_visibility(visibility_timeout)
    queue.change_message_visibility receipt_handle, visibility_timeout
  end
  alias :visibility= :change_visibility

  def delete
    queue.delete_message receipt_handle
  end
end
