require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RAWS::S3.http = RAWS::HTTP::HT2P

RAWS_S3_BUCKETS.each do |bucket_name, location, acl|
  location_label = location ? location : 'US'

  describe RAWS::S3 do
    describe 'class' do
      before(:all) do
=begin
        response = RAWS::S3.create_bucket(bucket_name, location)
        response.should be_kind_of(RAWS::HTTP::Response)
=end
        begin
          RAWS::S3.put_object(bucket_name, 'aaa') do |request|
            request.send 'AAA'
          end

          RAWS::S3.put_object(bucket_name, 'bbb') do |request|
            request.header['content-length'] = 3
            request.send do |io|
             io.write 'BBB'
            end
          end

          RAWS::S3.put_object(bucket_name, 'ccc') do |request|
            request.send 'CCC'
          end
        rescue => e
          d e
        end
      end
=begin
      after(:all) do
        response = RAWS::S3.delete_bucket(bucket_name, :force)
        response.should be_kind_of(RAWS::HTTP::Response)

        sleep 30
      end
=end
      it "owner should return a owner information of the bucket" do
        RAWS::S3.owner.should be_instance_of(RAWS::S3::Owner)
        RAWS::S3.owner.display_name.should be_instance_of(String)
        RAWS::S3.owner.id.should be_instance_of(String)
      end

      it "buckets should return an array of RAWS::S3" do
       RAWS::S3.list_buckets.should be_instance_of(Array)
       RAWS::S3.list_buckets.each do |bucket|
         bucket.should be_instance_of(RAWS::S3)
       end
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

      it "filter('#{bucket_name}')" do
        RAWS::S3.filter(bucket_name) do |object|
          object.should be_instance_of(Hash)
        end
      end

      it 'put_object, get_object and delete_object method should put, get and delete the object' do
        RAWS::S3.put_object(bucket_name, 'a') do |request|
          request.should be_kind_of(RAWS::HTTP::Request)

          response = request.send('AAA')

          response.should be_kind_of(RAWS::HTTP::Response)
        end

        RAWS::S3.get_object(bucket_name, 'a') do |request|
          request.should be_kind_of(RAWS::HTTP::Request)

          response = request.send
          response.receive.should == 'AAA'

          response.should be_kind_of(RAWS::HTTP::Response)
        end

        response = RAWS::S3.delete_object(bucket_name, 'a')
        response.should be_kind_of(RAWS::HTTP::Response)

        lambda do
          RAWS::S3.get_object(bucket_name, 'a')
        end.should raise_error(RAWS::HTTP::Error)
      end

      it "copy_object method should copy the object" do
        response = RAWS::S3.copy_object(bucket_name, 'aaa', bucket_name, 'AAA')
        response.should be_kind_of(RAWS::HTTP::Response)

        src = nil
        RAWS::S3.get_object(bucket_name, 'aaa') do |request|
          src = request.send.receive
        end

        dest = nil
        RAWS::S3.get_object(bucket_name, 'AAA') do |request|
          dest = request.send.receive
        end

        dest.should == src

        response = RAWS::S3.delete_object(bucket_name, 'AAA')
        response.should be_kind_of(RAWS::HTTP::Response)
      end

      it "head_object method should return header information of the object" do
        response = RAWS::S3.head_object(bucket_name, 'aaa')
        response.should be_kind_of(RAWS::HTTP::Response)
      end
    end

    describe 'object' do
      before(:all) do
        @bucket = RAWS::S3[bucket_name]
        #@bucket.create_bucket.should be_kind_of(RAWS::HTTP::Response)

        @bucket.put('aaa') do |request| request.send 'AAA' end
        @bucket.put('bbb') do |request|
          request.header['content-length'] = 3
          request.send do |io|
            io.write 'AAA'
          end
        end
        @bucket.put('ccc') do |request| request.send 'CCC' end
      end
=begin
      after(:all) do
        response = @bucket.delete_bucket(:force)
        response.should be_kind_of(RAWS::HTTP::Response)

        sleep 30
      end
=end
      it "location should return location of the bucket" do
        @bucket.location.should == location_label
      end

      it "filter should" do
        @bucket.filter do |object|
          object.should be_instance_of(Hash)
        end
      end

      it 'put, get and delete method should put, get and delete the object' do
        @bucket.put('a') do |request|
          request.should be_kind_of(RAWS::HTTP::Request)

          response = request.send('AAA')

          response.should be_kind_of(RAWS::HTTP::Response)
        end

        @bucket.get('a') do |request|
          request.should be_kind_of(RAWS::HTTP::Request)

          response = request.send
          response.receive.should == 'AAA'

          response.should be_kind_of(RAWS::HTTP::Response)
        end

        @bucket.delete('a').should be_kind_of(RAWS::HTTP::Response)

        lambda do
          @bucket.get('a')
        end.should raise_error(RAWS::HTTP::Error)
      end

      it "copy method should copy the object" do
        response = @bucket.copy('aaa', bucket_name, 'AAA')
        response.should be_kind_of(RAWS::HTTP::Response)

        src = nil
        @bucket.get('aaa') do |request|
          src = request.send.receive
        end

        dest = nil
        @bucket.get('AAA') do |request|
          dest = request.send.receive
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
