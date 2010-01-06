class RAWS::SQS::Message
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
