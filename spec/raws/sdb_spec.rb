require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RAWS::SDB do
  before :all do
    RAWS_SDB_DOMAINS.each do |name|
      RAWS::SDB.create_domain(name)
    end
    puts '[sleep 60 secs]'
    sleep 60
    @domain_name = RAWS_SDB_DOMAINS.first
    RAWS::SDB[@domain_name].put(
      '100', 'a' => 10
    )
    RAWS::SDB[@domain_name].put(
      '200', 'a' => [10, 20],     'b' => 20
    )
    RAWS::SDB[@domain_name].put(
      '300', 'a' => [10, 20, 30], 'b' => 20, 'c' => 30
    )
    RAWS::SDB[@domain_name].batch_put(
      "400" => {"a"=>["10", "20", "30", "40"]},
      "500" => {"a"=>["10", "20", "30", "40", "50"]},
      "600" => {"a"=>["10", "20", "30", "40", "50", "60"]}
    )
  end

  after :all do
    RAWS_SDB_DOMAINS.each do |name|
      RAWS::SDB.delete_domain(name)
    end
    puts '[sleep 60 secs]'
    sleep 60
  end

  describe 'class' do
    it 'methods' do
      %w'
        create_domain
        delete_domain
        metadata
        list
        domains
        each
        []
        select
        all
        get
        put
        batch_put
        delete
      '.each do |val|
        RAWS::SDB.should respond_to val.to_sym
      end
    end

    it 'create_domain' do
    end

    it 'delete_domain' do
    end

    it 'metadata' do
      data = RAWS::SDB.metadata(@domain_name)
      data.should have_key('Timestamp')
      data.should have_key('ItemCount')
      data.should have_key('AttributeValueCount')
      data.should have_key('AttributeNameCount')
      data.should have_key('ItemNamesSizeBytes')
      data.should have_key('AttributeValuesSizeBytes')
      data.should have_key('AttributeNamesSizeBytes')
    end

    it 'list' do
      data = RAWS::SDB.list
      data.should have_key('DomainName')

      data = RAWS::SDB.list(nil, 1)
      data['DomainName'].should be_kind_of(Array)
      data['DomainName'].size.should == 1
      data['DomainName'].first.should be_kind_of(String)
      data.should have_key('NextToken')
    end

    it 'domains' do
      domains = RAWS::SDB.domains
      domains.should have_key('Domains')

      data = RAWS::SDB.domains(nil, 1)
      data['Domains'].should be_kind_of(Array)
      data['Domains'].size.should == 1
      data['Domains'].first.should be_kind_of(RAWS::SDB)
      data.should have_key('NextToken')
    end

    it 'each' do
      RAWS::SDB.each do |domain|
        domain.should be_kind_of(RAWS::SDB)
      end
    end

    it '[]' do
      RAWS::SDB[@domain_name].should be_kind_of(RAWS::SDB)
    end

    it 'select' do
      RAWS::SDB[@domain_name].select do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end

      RAWS::SDB[@domain_name].select.where('b = ?', 20) do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end
    end

    it 'all' do
      RAWS::SDB[@domain_name].all do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end

      RAWS::SDB[@domain_name].all.filter('b = ?', 20) do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end
    end

    it 'get' do
      RAWS::SDB[@domain_name].get('000').should be_nil

      data = RAWS::SDB[@domain_name].get('100')
      data.should == {'a' => '10'}

      data = RAWS::SDB[@domain_name].get('200')
      data.should == {'a' => ['10', '20'], 'b' => '20'}

      data = RAWS::SDB[@domain_name].get('300')
      data.should == {'a' => ['10', '20', '30'], 'b' => '20', 'c' => '30'}
    end

    it 'put, get & delete' do
      RAWS::SDB[@domain_name].put('10', 'a' => [1])
      RAWS::SDB[@domain_name].put('10', 'a' => 2)

      5.times do
        data = RAWS::SDB[@domain_name].get('10')
        if data == {'a' => ['1', '2']}
          data.should == {'a' => ['1', '2']}
          break;
        end
      end

      RAWS::SDB[@domain_name].delete('10')

      5.times do
        data = RAWS::SDB[@domain_name].get('10')
        unless data
          data.should be_nil
        end
      end
    end

    it 'batch_put & delete' do
      RAWS::SDB[@domain_name].batch_put(
        "1" => {"a"=>["10"]},
        "2" => {"a"=>["20"]},
        "3" => {"a"=>["30"]}
      )

      5.times do
        data = RAWS::SDB[@domain_name].get('1')
        if data
          data.should == {'a' => '10'}
          RAWS::SDB[@domain_name].delete('1')
          break
        end
      end

      5.times do
        data = RAWS::SDB[@domain_name].get('2')
        if data
          data.should == {'a' => '20'}
          RAWS::SDB[@domain_name].delete('2')
          break
        end
      end

      5.times do
        data = RAWS::SDB[@domain_name].get('3')
        if data
          data.should == {'a' => '30'}
          RAWS::SDB[@domain_name].delete('3')
          break
        end
      end

      5.times do
        data = RAWS::SDB[@domain_name].get('1')
        unless data
          data.should be_nil
          break
        end
      end

      5.times do
        data = RAWS::SDB[@domain_name].get('2')
        unless data
          data.should be_nil
          break
        end
      end

      5.times do
        data = RAWS::SDB[@domain_name].get('3')
        unless data
          data.should be_nil
          break
        end
      end
    end
  end

  describe 'object' do
    before do
      @domain_name = RAWS_SDB_DOMAINS.first
      @sdb = RAWS::SDB[@domain_name]
    end

    it 'method' do
      %w'
        create_domain
        delete_domain
        metadata
        select
        all
        get
        put
        batch_put
        delete
      '.each do |val|
        @sdb.should respond_to val.to_sym
      end
    end

    it 'create_domain' do
      #@sdb.create_domain
    end

    it 'delete_domain' do
      #@sdb.delete_domain
    end

    it 'metadata' do
      data = @sdb.metadata
      data.should have_key('Timestamp')
      data.should have_key('ItemCount')
      data.should have_key('AttributeValueCount')
      data.should have_key('AttributeNameCount')
      data.should have_key('ItemNamesSizeBytes')
      data.should have_key('AttributeValuesSizeBytes')
      data.should have_key('AttributeNamesSizeBytes')
    end

    it 'select' do
      @sdb.select do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end

      @sdb.select.where('b = ?', 20) do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end
    end

    it 'all' do
      @sdb.all do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end

      @sdb.all.filter('b = ?', 20) do |val|
        val.first.should be_kind_of(String)
        val.last.should be_kind_of(Hash)
      end
    end

    it 'get' do
      @sdb.get('000').should be_nil

      data = @sdb.get('100')
      data.should == {'a' => '10'}

      data = @sdb.get('200')
      data.should == {'a' => ['10', '20'], 'b' => '20'}

      data = @sdb.get('300')
      data.should == {'a' => ['10', '20', '30'], 'b' => '20', 'c' => '30'}
    end

    it 'put, get & delete' do
      @sdb.put('10', 'a' => 1)

      5.times do
        data = @sdb.get('10')
        if data
          data.should == {'a' => '1'}
          break
        end
      end

      @sdb.delete('10')

      5.times do
        data = @sdb.get('10')
        unless data
          data.should be_nil
          break
        end
      end
    end

    it 'batch_put' do
      @sdb.batch_put(
        "1" => {"a"=>["10"]},
        "2" => {"a"=>["20"]},
        "3" => {"a"=>["30"]}
      )

      5.times do
        data = @sdb.get('1')
        if data
          data.should == {'a' => '10'}
          @sdb.delete('1')
          break
        end
      end

      5.times do
        data = @sdb.get('2')
        if data
          data.should == {'a' => '20'}
          @sdb.delete('2')
          break
        end
      end

      5.times do
        data = @sdb.get('3')
        if data
          data.should == {'a' => '30'}
          @sdb.delete('3')
          break
        end
      end

      5.times do
        data = @sdb.get('1')
        unless data
          data.should be_nil
          break
        end
      end

      5.times do
        data = @sdb.get('2')
        unless data
          data.should be_nil
          break
        end
      end

      5.times do
        data = @sdb.get('3')
        unless data
          data.should be_nil
          break
        end
      end
    end
  end
end
