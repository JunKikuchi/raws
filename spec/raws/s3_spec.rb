require 'spec/spec_config'

describe RAWS::S3 do
  describe 'class' do
    it 'list_backets' do
      begin
        p RAWS::S3.list
      rescue RAWS::Error => e
        p e.response.code
        p e.data
      rescue => e
        p e
      end
    end
  end
end
