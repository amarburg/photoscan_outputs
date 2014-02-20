
require "minitest/autorun"
require "photoscan_outputs"

class TestCameraFile < MiniTest::Unit::TestCase

  include PhotoscanOutputs

  def demo_cameras_xml
    Pathname.new(__FILE__).parent.parent.join("demo", "cameras.xml")
  end

  def test_loads_a_file
    cameras = CameraFile.load( demo_cameras_xml )
    assert_kind_of( CameraFile, cameras )
  end

end
