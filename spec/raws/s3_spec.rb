require 'spec/spec_config'

describe RAWS::S3::Adapter do
  describe 'class' do
    it 'get_service' do
      begin
        p RAWS::S3::Adapter.get_service
      rescue RAWS::Error => e
        p e.response.code
        p e.data
      rescue => e
        p e
      end
    end

    it 'put_bucket' do
      begin
        #p RAWS::S3::Adapter.delete_bucket('kikuchitestbucket')
        #p RAWS::S3::Adapter.put_bucket('kikuchitestbucket')
      rescue RAWS::Error => e
        p e.response.code
        p e.data
      rescue => e
        p e
      end
    end
  end
end
