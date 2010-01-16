require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class SDBModel
  include RAWS::SDB::Model
  self.domain_name = RAWS_SDB_DOMAINS.first
end

describe RAWS::SDB::Model do
  describe 'class' do
    before do
      SDBModel.delete('1')
      SDBModel.delete('2')
      SDBModel.delete('3')

      SDBModel.put('1', 'a' => '10')
      SDBModel.put('2', 'b' => '10')
      SDBModel.put('3', 'c' => '10')
    end

    after do
      SDBModel.delete('1')
      SDBModel.delete('2')
      SDBModel.delete('3')
    end

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
        delete_attributes
        delete

        domain_name

        domain
        select
        all
        find
        create_id
      '.each do |val|
        SDBModel.should respond_to val.to_sym
      end
    end

    it 'domain_name' do
      SDBModel.domain_name.should == RAWS_SDB_DOMAINS.first
    end

    it 'get, put & delete' do
      SDBModel.get('1').should == {'a' => '10'}
      SDBModel.get('2').should == {'b' => '10'}
      SDBModel.get('3').should == {'c' => '10'}

      SDBModel.put('1', 'a' => '20', 'b' => '10')
      SDBModel.get('1').should == {'a' => ['10', '20'], 'b' => '10'}

      SDBModel.delete('1')
      SDBModel.delete('2')
      SDBModel.delete('3')

      SDBModel.get('1').should be_nil
      SDBModel.get('2').should be_nil
      SDBModel.get('3').should be_nil
    end

    it 'batch_put' do
      SDBModel.batch_put(
        '1' => {'a' => '20', 'b' => '10'},
        '2' => {'b' => '20'},
        '3' => {'c' => '20'}
      )

      SDBModel.get('1').should == {'a' => ['10', '20'], 'b' => '10'}
      SDBModel.get('2').should == {'b' => ['10', '20']}
      SDBModel.get('3').should == {'c' => ['10', '20']}
    end

    it 'all' do
      SDBModel.all.each do |model|
        model.should be_instance_of SDBModel
      end
    end

    it 'find' do
      model = SDBModel.find('1')
      model.should be_instance_of SDBModel

      model = SDBModel.find('0')
      model.should be_nil
    end
  end

  describe 'object' do
    it 'methods' do
      model = SDBModel.new
      %w'
        create_id
        exists?
        []
        []=
        delete
        save
      '.each do |val|
        model.should respond_to val.to_sym
      end
    end

    it 'operations' do
      model = SDBModel.find('0')
      model.should be_nil

      model = SDBModel.new
      model['a'] = '1'
      model['b'] = '2'
      model['c'] = '3'
      model.save
      id = model.id

      model = SDBModel.find(id)
      model['a'].should == '1'
      model['b'].should == '2'
      model['c'].should == '3'

      model.delete

      model = SDBModel.find(id)
      model.should be_nil
    end
  end
end
