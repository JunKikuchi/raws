require 'helper'

class TestRAWS_XML_Nokogiri < Test::Unit::TestCase
  should 'parse' do
    assert_equal({}, RAWS::XML::Nokogiri.parse(''))

    assert_equal(
      {'tag' => nil},
      RAWS::XML::Nokogiri.parse('<tag/>')
    )

    assert_equal(
      {'tag' => 'text'},
      RAWS::XML::Nokogiri.parse('<tag>text</tag>')
    )

    assert_equal(
      {'tag' => {'tag1' => 'text1', 'tag2' => 'text2'}},
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1>text1</tag1><tag2>text2</tag2></tag>'
      )
    )

    assert_equal(
      {'tag' => {'tag1' => ['text1', 'text2']}},
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1>text1</tag1><tag1>text2</tag1></tag>'
      )
    )

    assert_equal(
      {'tag' => {'tag1' => ['text1', 'text2']}},
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1>text1</tag1><tag1>text2</tag1></tag>',
        :multiple => ['tag1']
      )
    )

    assert_equal(
      {'tag' => {'tag1' => ['text1']}},
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1>text1</tag1></tag>',
        :multiple => ['tag1']
      )
    )

    assert_equal(
      {'tag' => {'tag1' => ['text1', 'text2']}},
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1>text1</tag1><tag1>text2</tag1></tag>',
        :multiple => ['tag1']
      )
    )

    assert_equal(
      {'tag' => {'name' => 'value'}},
      RAWS::XML::Nokogiri.parse(
        '<tag><Name>name</Name><Value>value</Value></tag>',
        :unpack => ['tag']
      )
    )

    assert_equal(
      {'tag' => [{'name' => 'value'}]},
      RAWS::XML::Nokogiri.parse(
        '<tag><Name>name</Name><Value>value</Value></tag>',
        :multiple => ['tag'],
        :unpack   => ['tag']
      )
    )

    assert_equal(
      {
        'tag' => {
          'tag1' => {'name' => 'value'},
          'tag2' => {'name' => 'value'}
        }
      },
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1><Name>name</Name><Value>value</Value></tag1><tag2><Name>name</Name><Value>value</Value></tag2></tag>',
        :unpack => ['tag1', 'tag2']
      )
    )

    assert_equal(
      {
        'tag' => {
          'tag1' => [
            {'name1' => 'value1'},
            {'name2' => 'value2'}
          ]
        }
      },
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1><Name>name1</Name><Value>value1</Value></tag1><tag1><Name>name2</Name><Value>value2</Value></tag1></tag>',
        :unpack => ['tag1']
      )
    )

    assert_equal(
      {
        'tag' => {
          'tag1' => [
            {'name1' => 'value1'},
            {'name2' => 'value2'}
          ]
        }
      },
      RAWS::XML::Nokogiri.parse(
        '<tag><tag1><Name>name1</Name><Value>value1</Value></tag1><tag1><Name>name2</Name><Value>value2</Value></tag1></tag>',
        :multiple => ['tag1'],
        :unpack   => ['tag1']
      )
    )
  end
end
