
require "ox"
require "photoscan_outputs/camera"

module PhotoscanOutputs

  class CameraFile
    attr_reader :cameras, :global_transform

    include Enumerable

    def initialize( cameras, global )
      @cameras = cameras
      @global_transform = global
    end

    def find_by_name( name )
      find { |cam| cam.name ==  name }
    end

    def each
      if block_given?
        @cameras.each { |blk| yield blk }
      else
        @cameras.each
      end
    end


    def self.load( file )
      raise "Can't read file \"#{file}\"" unless File.readable? file

      xml = Ox.load File.read( file )

      cameras = xml.locate("collection/cameras").first.nodes

      global = Transform.from_xml xml.locate("collection").first.transform

      cameras.map! { |cam|
        Camera.from_xml( cam, global )
      }

      CameraFile.new( cameras, global )
    end

  end
end


