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

  class Grants < Array
    def initialize(grants)
      super()
      grants.each do |grant|
        grantee = grant['Grantee']
        if grantee['ID']
          push Grant::ID.new(grant)
        elsif grantee['EmailAddress']
          push Grant::Email.new(grant)
        else
          case grantee['URI']
          when 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
            push Grant::Group.new(grant)
          when 'http://acs.amazonaws.com/groups/global/AllUsers'
            push Grant::Anonymouse.new(grant)
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

  class Grant
    class ID < Grant
      attr_accessor :id, :name

      def initialize(grant)
        super
        grantee = grant['Grantee']
        @id, @name = grantee['ID'], grantee['DisplayName']
      end

      def to_xml
        '<Grant>' <<
          '<Grantee xsi:type="CanonicalUser">' <<
            "<ID>#{@id}</ID>" <<
            "<DisplayName>#{@name}</DisplayName>" <<
          '</Grantee>' <<
          super <<
        '</Grant>'
      end
    end

    class Email < Grant
      attr_accessor :email

      def initialize(grant)
        super
        @email = grant['Grantee']['EmailAddress']
      end

      def to_xml
        '<Grant>' <<
          '<Grantee xsi:type="AmazonCustomerByEmail">' <<
            "<EmailAddress>#{@email}</EmailAddress>" <<
          '</Grantee>' <<
          super <<
        '</Grant>'
      end
    end

    class Group < Grant
      def initialize(grant)
        super
        @uri = grant['Grantee']['URI']
      end

      def to_xml
        '<Grant>' <<
          '<Grantee xsi:type="Group">' <<
            "<URI>#{@uri}</URI>" <<
          '</Grantee>' <<
          super <<
        '</Grant>'
      end
    end

    class Anonymouse < Group; end

    attr_accessor :permission

    def initialize(grant)
      @permission = grant['Permission']
    end

    def to_xml
      "<Permission>#{@permission}</Permission>"
    end
  end

  attr_reader :owner, :grants

  def initialize(doc)
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
