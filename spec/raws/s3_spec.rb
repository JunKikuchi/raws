require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RAWS::S3 do
  RAWS_S3_BUCKETS.each do |bucket_name, location, acl|
    location_label = location ? location : 'US'

    before(:all) do
#      RAWS::S3.create_bucket bucket_name, location
#      RAWS::S3.put bucket_name, 'aaa', 'AAA'
#      RAWS::S3.put bucket_name, 'bbb', 'BBB'
#      RAWS::S3.put bucket_name, 'ccc', 'CCC'
    end

    after(:all) do
#      RAWS::S3.delete_bucket bucket_name, :force
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
      RAWS::S3.location(bucket_name).should == location_label
    end

    it "filter('#{bucket_name}') should return an array of RAWS::S3::Object" do
      RAWS::S3.filter(bucket_name).should be_instance_of(Array)
      RAWS::S3.filter(bucket_name).each do |object|
        object.should be_instance_of(Hash)
      end
    end

    it 'put, get and delete method should put, get and delete the object' do
      RAWS::S3.put(bucket_name, 'a', 'A')

      response = RAWS::S3.get(bucket_name, 'a')
      response.should be_kind_of RAWS::HTTP::Response

      RAWS::S3.delete(bucket_name, 'a')

      begin
        response = RAWS::S3.get(bucket_name, 'a')
        response.should be_nil
      rescue => e
        d e
      end
    end

    it "copy(src_bucket, src_name, dest_bucket, dest_name) should copy the object"
    it "head('#{bucket_name}', name) should head the object"
  end
end
