require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RAWS::S3.http = RAWS::HTTP::HT2P

RAWS_S3_BUCKETS.each do |bucket_name, location, acl|
  location_label = location ? location : 'US'

  describe RAWS::S3 do
    describe 'class' do
      before(:all) do
        response = RAWS::S3.create_bucket(bucket_name, location)
        response.should be_kind_of(RAWS::HTTP::Response)

        RAWS::S3.put(
          bucket_name,
          'aaa',
          'content-length' => 3
        ) do |io|
          io.write 'AAA'
        end

        RAWS::S3.put(
          bucket_name,
          'bbb',
          'content-length' => 3
        ) do |io|
          io.write 'BBB'
        end

        RAWS::S3.put(
          bucket_name,
          'ccc',
          'content-length' => 3
        ) do |io|
          io.write 'CCC'
        end
      end

      after(:all) do
        response = RAWS::S3.delete_bucket(bucket_name, :force)
        response.should be_kind_of(RAWS::HTTP::Response)

        sleep 30
      end

      it "owner should return a owner information of the bucket" do
        RAWS::S3.owner.should be_instance_of(Hash)
        RAWS::S3.owner['DisplayName'].should be_instance_of(String)
        RAWS::S3.owner['ID'].should be_instance_of(String)
      end

      it "buckets should return an array of RAWS::S3" do
       RAWS::S3.buckets.should be_instance_of(Array)
       RAWS::S3.buckets.each do |bucket|
         bucket.should be_instance_of(RAWS::S3)
       end
       RAWS::S3.buckets.should include(RAWS::S3[bucket_name])
      end

      it "self['#{bucket_name}'] should be instance of RAWS::S3" do
        RAWS::S3[bucket_name].should be_instance_of(RAWS::S3)
        RAWS::S3[bucket_name].bucket_name.should == bucket_name
        RAWS::S3[bucket_name].name.should == bucket_name
      end

      it "location('#{bucket_name}') should return location of the bucket" do
        begin
          RAWS::S3.location(bucket_name).should == location_label
        rescue => e
          d e.response.doc
        end
      end

      it "filter('#{bucket_name}') should return an array of RAWS::HTTP::Response" do
        RAWS::S3.filter(bucket_name).should be_instance_of(Array)
        RAWS::S3.filter(bucket_name).each do |object|
          object.should be_instance_of(Hash)
        end
      end

      it 'put, get and delete method should put, get and delete the object' do
        response = RAWS::S3.put(bucket_name, 'a', 'content-length' => 1) do |io|
          io.write 'A'
        end
        response.should be_kind_of(RAWS::HTTP::Response)

        response = RAWS::S3.get(bucket_name, 'a') do |io|
          io.read
        end
        response.should be_kind_of(RAWS::HTTP::Response)

        response = RAWS::S3.delete(bucket_name, 'a')
        response.should be_kind_of(RAWS::HTTP::Response)

        lambda do
          RAWS::S3.get(bucket_name, 'a')
        end.should raise_error(RAWS::HTTP::Error)
      end

      it "copy method should copy the object" do
        response = RAWS::S3.copy(bucket_name, 'aaa', bucket_name, 'AAA')
        response.should be_kind_of(RAWS::HTTP::Response)

        src = nil
        RAWS::S3.get(bucket_name, 'aaa') do |io|
          src = io.read
        end

        dest = nil
        RAWS::S3.get(bucket_name, 'AAA') do |io|
          dest = io.read
        end

        dest.should == src

        response = RAWS::S3.delete(bucket_name, 'AAA')
        response.should be_kind_of(RAWS::HTTP::Response)
      end

      it "head method should return header information of the object" do
        response = RAWS::S3.head(bucket_name, 'aaa')
        response.should be_kind_of(RAWS::HTTP::Response)
      end
    end

    describe 'object' do
      before(:all) do
        @bucket = RAWS::S3[bucket_name]
        @bucket.create_bucket.should be_kind_of(RAWS::HTTP::Response)

        @bucket.put('aaa', 'content-length' => 3) do |io| io.write 'AAA' end
        @bucket.put('bbb', 'content-length' => 3) do |io| io.write 'BBB' end
        @bucket.put('ccc', 'content-length' => 3) do |io| io.write 'CCC' end
      end

      after(:all) do
        response = @bucket.delete_bucket(:force)
        response.should be_kind_of(RAWS::HTTP::Response)

        sleep 30
      end

      it "location should return location of the bucket" do
        @bucket.location.should == location_label
      end

      it "filter should return an array of RAWS::HTTP::Response" do
        @bucket.filter.should be_instance_of(Array)
        @bucket.filter.each do |object|
          object.should be_instance_of(Hash)
        end
      end

      it 'put, get and delete method should put, get and delete the object' do
        @bucket.put('a', 'content-length' => 1) do |io|
          io.write 'A'
        end.should be_kind_of(RAWS::HTTP::Response)

        @bucket.get('a') do |io|
          io.read
        end.should be_kind_of(RAWS::HTTP::Response)

        @bucket.delete('a').should be_kind_of(RAWS::HTTP::Response)

        lambda do
          @bucket.get('a')
        end.should raise_error(RAWS::HTTP::Error)
      end

      it "copy method should copy the object" do
        response = @bucket.copy('aaa', bucket_name, 'AAA')
        response.should be_kind_of(RAWS::HTTP::Response)

        src = nil
        @bucket.get('aaa') do |io|
          src = io.read
        end

        dest = nil
        @bucket.get('AAA') do |io|
          dest = io.read
        end

        dest.should == src

        @bucket.delete('AAA').should be_kind_of(RAWS::HTTP::Response)
      end

      it "head method should return header information of the object" do
        @bucket.head('aaa').should be_kind_of(RAWS::HTTP::Response)
      end
    end
  end
=begin
  describe RAWS::S3::S3Object do
    class S3 < RAWS::S3::S3Object
      self.bucket_name = bucket_name
    end

    describe 'class' do
      before(:all) do
#        S3.create_bucket
      end

      after(:all) do
#        S3.delete_bucket
#        sleep 60
      end

      it "location should return location of the bucket"
      it "filter should return an array of RAWS::S3::Object"
      it "create method should put the object"
    end

    describe 'object' do
    end
  end
=end
end
