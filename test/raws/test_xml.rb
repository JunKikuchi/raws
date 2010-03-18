require 'helper'

class TestRAWS_XML < Test::Unit::TestCase
  should 'unpack_attrs' do
    assert_equal({}, RAWS::XML.unpack_attrs(''))

    assert_equal({}, RAWS::XML.unpack_attrs({}))

    assert_equal({}, RAWS::XML.unpack_attrs([]))

    assert_equal(
      {'name' => 'value'},
      RAWS::XML.unpack_attrs({'Name' => 'name', 'Value' => 'value'})
    )

    assert_equal(
      {'name1' => 'value1', 'name2' => 'value2'},
      RAWS::XML.unpack_attrs(
        [
          {'Name' => 'name1', 'Value' => 'value1'},
          {'Name' => 'name2', 'Value' => 'value2'}
        ]
      )
    )

    assert_equal(
      {'name1' => 'value1', 'name2' => ['value2', 'value2']},
      RAWS::XML.unpack_attrs(
        [
          {'Name' => 'name1', 'Value' => 'value1'},
          {'Name' => 'name2', 'Value' => 'value2'},
          {'Name' => 'name2', 'Value' => 'value2'},
        ]
      )
    )
  end
end
