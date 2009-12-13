class RAWS::S3::ACL
  class Owner
    attr_accessor :id, :name

    alias :display_name :name

    def initialize(owner)
      @id, @name = owner['ID'], owner['DisplayName']
    end

    def to_xml
      '<Owner>' <<
        "<ID>#{@id}</ID>" <<
        "<DisplayName>#{@name}</DisplayName>" <<
      '</Owner>'
    end
  end

  class Grant
    attr_accessor :permission

    def initialize(permission)
      @permission = permission
    end

    def to_xml
      "<Permission>#{@permission}</Permission>"
    end
  end

  class ID < Grant
    attr_accessor :id, :name

    def initialize(id, permission, name=nil)
      super(permission)
      @id, @name = id, name
    end

    def to_xml
      '<Grant>' <<
        '<Grantee' <<
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' <<
        ' xsi:type="CanonicalUser">' <<
          "<ID>#{@id}</ID>" <<
          (@name ? "<DisplayName>#{@name}</DisplayName>" : '') <<
        '</Grantee>' <<
        super <<
      '</Grant>'
    end
  end

  class Email < Grant
    attr_accessor :email

    def initialize(email, permission)
      super(permission)
      @email = email
    end

    def to_xml
      '<Grant>' <<
        '<Grantee' <<
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' <<
        ' xsi:type="AmazonCustomerByEmail">' <<
          "<EmailAddress>#{@email}</EmailAddress>" <<
        '</Grantee>' <<
        super <<
      '</Grant>'
    end
  end

  class Group < Grant
    def to_xml
      '<Grant>' <<
        '<Grantee' <<
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' <<
        ' xsi:type="Group">' <<
          "<URI>http://acs.amazonaws.com/groups/global/#{
            self.class.name.split('::').last
          }</URI>" <<
        '</Grantee>' <<
        super <<
      '</Grant>'
    end
  end

  class AuthenticatedUsers < Group; end

  class AllUsers < Group; end

  class Grants < Array
    def initialize(grants)
      super()
      grants.each do |grant|
        grantee, permission = grant['Grantee'], grant['Permission']
        if id = grantee['ID']
          push ID.new(id, permission, grantee['DisplayName'])
        elsif email = grantee['EmailAddress']
          push Email.new(email, permission)
        else
          case grantee['URI']
          when 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
            push AuthenticatedUsers.new(permission)
          when 'http://acs.amazonaws.com/groups/global/AllUsers'
            push AllUsers.new(permission)
          end
        end
      end
    end

    def to_xml
      '<AccessControlList>' <<
        map do |grant|
          grant.to_xml
        end.join <<
      '</AccessControlList>'
    end
  end

  attr_reader :bucket_name, :key, :owner, :grants

  def initialize(bucket_name, key=nil)
    @bucket_name, @key = bucket_name, key
    reload
  end

  def save
    RAWS::S3::Adapter.put_acl(@bucket_name, @key, to_xml)
  end

  def reload
    doc = RAWS::S3::Adapter.get_acl(@bucket_name, @key).doc
    acp = doc['AccessControlPolicy']
    @owner  = Owner.new(acp['Owner'])
    @grants = Grants.new(acp['AccessControlList']['Grant'])
  end

  def to_xml
    '<AccessControlPolicy>' <<
      owner.to_xml  <<
      grants.to_xml <<
    '</AccessControlPolicy>'
  end
end
