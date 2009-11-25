require 'spec/spec_helper'

describe RAWS::S3::ACL do
  before :all do
    acl =<<-END
<AccessControlPolicy><Owner><ID>a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9</ID><DisplayName>chriscustomer</DisplayName></Owner><AccessControlList><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>a9a7b886d6fd24a52fe8ca5bef65f89a64e0193f23000e241bf9b1c61be666e9</ID><DisplayName>chriscustomer</DisplayName></Grantee><Permission>FULL_CONTROL</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be</ID><DisplayName>Frank</DisplayName></Grantee><Permission>WRITE</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be</ID><DisplayName>Frank</DisplayName></Grantee><Permission>READ_ACP</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>e019164ebb0724ff67188e243eae9ccbebdde523717cc312255d9a82498e394a</ID><DisplayName>Jose</DisplayName></Grantee><Permission>WRITE</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser"><ID>e019164ebb0724ff67188e243eae9ccbebdde523717cc312255d9a82498e394a</ID><DisplayName>Jose</DisplayName></Grantee><Permission>READ_ACP</Permission></Grant><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Group"><URI>http://acs.amazonaws.com/groups/global/AllUsers</URI></Grantee><Permission>READ</Permission></Grant></AccessControlList></AccessControlPolicy>
    END

    @acl = RAWS::S3::ACL.new(RAWS.xml.parse(acl, :multiple => ['Grant']))
  end

  it '' do
    d @acl
    @acl.grants.each do |grant|
      p grant.class.name
    end
    d RAWS::S3::ACL.new(RAWS.xml.parse(@acl.to_xml, :multiple => ['Grant']))
  end
end
