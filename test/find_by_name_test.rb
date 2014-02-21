

require "minitest/autorun"
require "photoscan_outputs"

require_relative "common"

class TestFindByName < MiniTest::Unit::TestCase
  include PhotoscanOutputs
  include PhotoscanOutputsTestCommon

  def setup
    @cameras = CameraFile.load( demo_cameras_xml )
  end

  def test_find_by_name_by_string
    assert_kind_of Camera, @cameras.find_by_name( "IMG_7622.jpg" )
  end

  def test_find_by_name_by_substring
    assert_kind_of Camera, @cameras.find_by_name( "IMG_7622" )
  end

  def test_find_by_name_by_regexp
    assert_kind_of Camera, @cameras.find_by_name( /^IMG_7622/ )
  end

end
