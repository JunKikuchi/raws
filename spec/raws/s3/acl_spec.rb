require 'spec/spec_helper'

describe RAWS::S3::ACL::Grants do
  before :all do
    acp = '<AccessControlPolicy><Owner><ID>a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9</ID><DisplayName>chriscustomer</DisplayName></Owner><AccessControlList><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9</ID><DisplayName>chriscustomer</DisplayName></Grantee><Permission>FULL_CONTROL</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be</ID><DisplayName>Frank</DisplayName></Grantee><Permission>WRITE</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be</ID><DisplayName>Frank</DisplayName></Grantee><Permission>READ_ACP</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>e019164ebb0724ff67188e243eae9ccbebdde523717cc312255d9a82498e394a</ID><DisplayName>Jose</DisplayName></Grantee><Permission>WRITE</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>e019164ebb0724ff67188e243eae9ccbebdde523717cc312255d9a82498e394a</ID><DisplayName>Jose</DisplayName></Grantee><Permission>READ_ACP</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Group"><URI>http://acs.amazonaws.com/groups/global/AllUsers</URI></Grantee><Permission>READ</Permission></Grant></AccessControlList></AccessControlPolicy>'

    @grants = RAWS::S3::ACL::Grants.new(
      RAWS.xml.parse(
        acp,
        :multiple => ['Grant']
      )['AccessControlPolicy']['AccessControlList']['Grant']
    )
  end

  it 'grants should return array of grant' do
    @grants.should be_instance_of RAWS::S3::ACL::Grants

    @grants[0].should be_instance_of RAWS::S3::ACL::ID
    @grants[0].id.should == 'a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9'
    @grants[0].name.should == 'chriscustomer'
    @grants[0].permission.should == 'FULL_CONTROL'

    @grants.last.should be_instance_of RAWS::S3::ACL::Anonymouse
    @grants.last.permission.should == 'READ'
  end

  it 'to_xml should return access controll policy' do
    #@grants.to_xml.should == ""
  end
end
