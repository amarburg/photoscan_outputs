
require "minitest/autorun"
require "photoscan_outputs"

require_relative "common"

class TestCameraFile < MiniTest::Unit::TestCase

  include PhotoscanOutputs
  include PhotoscanOutputsTestCommon

  def test_loads_a_file
    cameras = CameraFile.load( demo_cameras_xml )
    assert_kind_of( CameraFile, cameras )
  end

end
