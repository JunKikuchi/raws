require 'spec/spec_config'

describe JAWS::SQS do
  describe 'class' do
    it 'methods' do
      %w'
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
        JAWS::SQS.should respond_to val.to_sym
      end
    end
  end

  describe 'object' do
    before do
    end
  end
end
