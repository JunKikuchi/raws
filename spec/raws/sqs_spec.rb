require 'spec/spec_config'

describe RAWS::SQS do
  before :all do
    RAWS::SQS.create_queue(RAWS_SQS_QUEUE)
    puts '[waiting 60 secs]'
    sleep 60
  end

  after :all do
    RAWS::SQS[RAWS_SQS_QUEUE].delete_queue
    puts '[waiting 60 secs]'
    sleep 60
  end

  describe 'class' do
    it 'methods' do
      %w'
        queue_url
        create_queue
        delete_queue
        list
        each
        []
        get_attrs
        set_attrs
        send
        receive
      '.each do |val|
        RAWS::SQS.should respond_to val.to_sym
      end
    end

    it 'list' do
      RAWS::SQS.list.each do |queue|
        queue.should be_kind_of RAWS::SQS
      end
    end

    it 'each' do
      RAWS::SQS.each do |queue|
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
        delete_queue
        get_attrs
        set_attrs
        send
        receive
        delete_message
        add_permission
        remove_permission
      '.each do |val|
        @queue.should respond_to val.to_sym
      end
    end

    it 'get_attrs' do
      attrs = @queue.get_attrs
      %w'
        ApproximateNumberOfMessages
        LastModifiedTimestamp
        CreatedTimestamp
        VisibilityTimeout
      '.each do |val|
        attrs.should have_key val
      end

      attrs = @queue.get_attrs 'VisibilityTimeout'
      attrs.should have_key 'VisibilityTimeout'
    end

    it 'set_attrs' do
      @queue.set_attrs 'VisibilityTimeout' => 60
      5.times do
        attrs = @queue.get_attrs 'VisibilityTimeout'
        if attrs['VisibilityTimeout'] == 60
          attrs['VisibilityTimeout'].should == 60
          break
        end
      end

      @queue.set_attrs 'VisibilityTimeout' => 30
      5.times do
        attrs = @queue.get_attrs 'VisibilityTimeout'
        if attrs['VisibilityTimeout'] == 30
          attrs['VisibilityTimeout'].should == 30
          break
        end
      end
    end

    it 'send, receive & delete' do
      5.times do |i|
        @queue.send(i)
      end

      i = 1
      while i <= 5 
        @queue.receive.each do |msg|
          msg.should be_kind_of RAWS::SQS::Message
          msg.delete
          i += 1
        end
      end
    end

    it 'change_message_visibility' do
=begin
      5.times do |i|
        p i
        @queue.receive.each do |msg|
          msg.delete
        end
        sleep 5
      end
=end
      @queue.send('change message visibility')

      msg_id, time = nil, nil
      loop do
        if msg = @queue.receive.first
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
          msg.visibility = 10
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
