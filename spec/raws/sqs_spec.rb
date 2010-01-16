require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RAWS::SQS do
=begin
  before :all do
    begin
      RAWS::SQS.create_queue(RAWS_SQS_QUEUE)
      puts '[waiting 61 secs]'
      sleep 61
    rescue => e
      d e
    end
  end

  after :all do
    begin
      RAWS::SQS[RAWS_SQS_QUEUE].delete_queue
      puts '[waiting 61 secs]'
      sleep 61
    rescue => e
      d e
    end
  end
=end

  describe 'class' do
    it 'methods' do
      %w'
        http
        queue_url
        create_queue
        delete_queue
        list_queues
        each
        queues
        []
        get_queue_attributes
        set_queue_attributes
        send_message
        send
        receive_message
        receive
        change_message_visibility
        delete_message
        add_permission
        remove_permission
      '.each do |val|
        RAWS::SQS.should respond_to val.to_sym
      end
    end

    it 'list_queues' do
      RAWS::SQS.list_queues.each do |queue|
        queue.should be_kind_of RAWS::SQS
      end
    end

    it '[]' do
      RAWS::SQS[RAWS_SQS_QUEUE].should be_kind_of RAWS::SQS
    end
  end

  describe 'object' do
    before do
      @queue = RAWS::SQS[RAWS_SQS_QUEUE]
    end

    it 'methods' do
      %w'
        queue_url
        queue_name
        delete_queue
        get_queue_attributes
        set_queue_attributes
        send_message
        send
        receive_message
        receive
        change_message_visibility
        delete_message
        add_permission
        remove_permission
        <=>
      '.each do |val|
        @queue.should respond_to val.to_sym
      end
    end

    it 'get_queue_attributes' do
      attrs = @queue.get_queue_attributes
      %w'
        ApproximateNumberOfMessages
        LastModifiedTimestamp
        CreatedTimestamp
        VisibilityTimeout
      '.each do |val|
        attrs.should have_key val
      end

      attrs = @queue.get_queue_attributes 'VisibilityTimeout'
      attrs.should have_key 'VisibilityTimeout'
    end

    it 'set_queue_attributes' do
      @queue.set_queue_attributes 'VisibilityTimeout' => 60
      5.times do
        attrs = @queue.get_queue_attributes 'VisibilityTimeout'
        if attrs['VisibilityTimeout'] == 60
          attrs['VisibilityTimeout'].should == 60
          break
        end
      end

      @queue.set_queue_attributes 'VisibilityTimeout' => 30
      5.times do
        attrs = @queue.get_queue_attributes 'VisibilityTimeout'
        if attrs['VisibilityTimeout'] == 30
          attrs['VisibilityTimeout'].should == 30
          break
        end
      end
    end

    it 'send_message, receive_message & delete_message' do
      5.times do |i|
        @queue.send_message(i)
      end

      i = 1
      while i <= 5 
        @queue.receive_message.each do |msg|
          msg.should be_kind_of RAWS::SQS::Message
          msg.delete
          i += 1
        end
      end
    end

    it 'change_message_visibility' do
      5.times do |i|
        #p i
        @queue.receive_message.each do |msg|
          msg.delete
        end
        sleep 5
      end
      @queue.send_message('change message visibility')

      msg_id, time = nil, nil
      loop do
        if msg = @queue.receive_message.first
          #p Time.now
          #p msg
          unless time
            msg_id = msg.data['MessageId']
            time   = Time.now.to_i
          else
            if msg_id == msg.data['MessageId']
              (time + 10).should <= Time.now.to_i
              msg.delete
              break
            end
          end
          msg.change_visibility(10)
        end
        #p 'sleep'
        sleep 5
      end
    end

    it 'add_permission'
    it 'remove_permission'

=begin
    it 'add_permission' do
      @queue.add_permission('p1', RAWS.aws_access_key_id => ['SendMessage'])
    end

    it 'remove_permission' do
      @queue.remove_permission('p1')
    end
=end
  end
end
