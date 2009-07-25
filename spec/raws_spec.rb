require 'spec/spec_config'

describe RAWS do
  describe 'class' do
    it 'methods' do
      %w'
        aws_access_key_id
        aws_secret_access_key
        escape
        sign
        fetch
      '.each do |val|
        RAWS.should respond_to val.to_sym
      end
    end

    it 'parse は XML を Array と Hash に変換する' do
      xml =<<-END
  <?xml version="1.0"?>
  <GetQueueAttributesResponse xmlns="http://queue.amazonaws.com/doc/2009-02-01/"><GetQueueAttributesResult><Attribute><Name>VisibilityTimeout</Name><Value>60</Value></Attribute></GetQueueAttributesResult><ResponseMetadata><RequestId>6f950716-2579-4c55-92e8-ff0cdec28e6d</RequestId></ResponseMetadata></GetQueueAttributesResponse>
      END
      data = RAWS.parse(
        Nokogiri::XML.parse(xml)
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Hash)

      data = RAWS.parse(
        Nokogiri::XML.parse(xml),
        :multiple => ['Attribute']
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Array)

      data = RAWS.parse(
        Nokogiri::XML.parse(xml),
        :unpack => ['Attribute']
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Hash)

      data = RAWS.parse(
        Nokogiri::XML.parse(xml),
        :multiple => ['Attribute'],
        :unpack => ['Attribute']
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Hash)

      xml =<<-END
  <?xml version="1.0"?>
  <GetQueueAttributesResponse xmlns="http://queue.amazonaws.com/doc/2009-02-01/"><GetQueueAttributesResult><Attribute><Name>VisibilityTimeout</Name><Value>60</Value></Attribute><Attribute><Name>ApproximateNumberOfMessages</Name><Value>7</Value></Attribute><Attribute><Name>CreatedTimestamp</Name><Value>1248498270</Value></Attribute><Attribute><Name>LastModifiedTimestamp</Name><Value>1248501553</Value></Attribute></GetQueueAttributesResult><ResponseMetadata><RequestId>6f950716-2579-4c55-92e8-ff0cdec28e6d</RequestId></ResponseMetadata></GetQueueAttributesResponse>
      END
      data = RAWS.parse(
        Nokogiri::XML.parse(xml)
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Array)

      data = RAWS.parse(
        Nokogiri::XML.parse(xml),
        :multiple => ['Attribute']
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Array)

      data = RAWS.parse(
        Nokogiri::XML.parse(xml),
        :unpack => ['Attribute']
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Hash)

      data = RAWS.parse(
        Nokogiri::XML.parse(xml),
        :multiple => ['Attribute'],
        :unpack => ['Attribute']
      )['GetQueueAttributesResponse']['GetQueueAttributesResult']['Attribute']
      data.should be_kind_of(Hash)
    end
  end
end
