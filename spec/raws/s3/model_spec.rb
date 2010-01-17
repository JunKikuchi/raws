require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class S3Object
  include RAWS::S3::Model
  self.bucket_name = RAWS_S3_BUCKETS[0][0]
end

describe RAWS::S3::Model do
  describe 'class' do
    it 'methods' do
      %w'
        create_bucket
        delete_bucket
        filter
        all
        find
      '.each do |val|
        S3Object.should respond_to val.to_sym
      end
    end
  end

  describe 'object' do
    before do
      @model = S3Object.new('a')
    end

    it 'methods' do
      %w'
        header
        metadata
        send
        receive
      '.each do |val|
        @model.should respond_to val.to_sym
      end
    end
  end
end
