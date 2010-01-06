require 'spec/spec_config'

class SDBModel
  include RAWS::SDB::Model
  self.domain_name = RAWS_SDB_DOMAINS.first
end

describe RAWS::SDB::Model do
  describe 'class' do
    it 'methods' do
      %w'
        create_domain
        delete_domain
        domain_metadata
        metadata
        get_attributes
        get
        put_attributes
        put
        batch_put_attributes
        batch_put
        delete_attribute
        delete

        domain
        select
        all
        create_id
      '.each do |val|
        SDBModel.should respond_to val.to_sym
      end
    end

    it 'domain_name' do
      SDBModel.domain_name.should == RAWS_SDB_DOMAINS.first
    end
  end

  describe 'object' do
    before do
      @model = SDBModel.new
    end

    it 'methods' do
      %w'
        create_id
        exists?
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
