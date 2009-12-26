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
    attr_accessor :grantee, :permission

    def initialize(grantee, permission)
      @grantee, @permission = grantee, permission
    end

    def to_xml
      '<Grant>' <<
        @grantee.to_xml <<
        "<Permission>#{@permission}</Permission>" <<
      '</Grant>'
    end
  end

  module Grantee
    class ID
      attr_accessor :id, :name

      def initialize(id, name=nil)
        @id, @name = id, name
      end

      def to_xml
        '<Grantee' <<
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' <<
        ' xsi:type="CanonicalUser">' <<
          "<ID>#{@id}</ID>" <<
          "<DisplayName>#{@name}</DisplayName>" <<
        '</Grantee>'
      end
    end

    class Email
      attr_accessor :email

      def initialize(email)
        @email = email
      end

      def to_xml
        '<Grantee' <<
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' <<
        ' xsi:type="AmazonCustomerByEmail">' <<
          "<EmailAddress>#{@email}</EmailAddress>" <<
        '</Grantee>'
      end
    end

    class Group < Grant
      def initialize(group=nil)
        @group = (group || self.class.name.split('::').last)
      end

      def to_xml
        '<Grantee' <<
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' <<
        ' xsi:type="Group">' <<
          "<URI>http://acs.amazonaws.com/groups/global/#{@group}</URI>" <<
        '</Grantee>' 
      end
    end

    class AuthenticatedUsers < Group; end

    class AllUsers < Group; end
  end

  class Grants < Array
    include RAWS::S3::ACL::Grantee

    def initialize(grants)
      super()
      grants.each do |grant|
        grantee, permission = grant['Grantee'], grant['Permission']
        if id = grantee['ID']
          push Grant.new(ID.new(id, grantee['DisplayName']), permission)
        elsif email = grantee['EmailAddress']
          push Grant.new(Email.new(email), permission)
        else
          case grantee['URI']
          when 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
            push Grant.new(AuthenticatedUsers.new, permission)
          when 'http://acs.amazonaws.com/groups/global/AllUsers'
            push Grant.new(AllUsers.new, permission)
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
    @owner = Owner.new(acp['Owner'])
    @grants = Grants.new(acp['AccessControlList']['Grant'])
  end

  def to_xml
    '<AccessControlPolicy>' <<
      owner.to_xml  <<
      grants.to_xml <<
    '</AccessControlPolicy>'
  end
end
