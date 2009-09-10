require 'spec/spec_config'

class SDBModel
  include RAWS::SDB::Model
  self.domain_name = RAWS_SDB_DOMAIN
end

describe RAWS::SDB::Model do
  describe 'class' do
    it 'methods' do
      %w'
        create_domain
        delete_domain
        select
        generate_id
      '.each do |val|
        SDBModel.should respond_to val.to_sym
      end
    end

    it 'domain_name' do
      SDBModel.domain_name.should == RAWS_SDB_DOMAIN
    end
  end

  describe 'object' do
    before do
      @model = SDBModel.new
    end

    it 'methods' do
      %w'
        []
        []=
        delete
        save
      '.each do |val|
        @model.should respond_to val.to_sym
      end
    end
  end
end
