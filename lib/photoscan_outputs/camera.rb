require "matrix"

module PhotoscanOutputs

  def print_mat( mat, io = STDOUT )
      mat.to_a.each { |row| io.puts row.map { |x| "% 10.5f" % x }.join('  ') }
  end

  class Calibration
    attr_accessor :fx, :fy, :cx, :cy, :skew

    def initialize( fx, fy, cx, cy, skew )
      @fx = fx
      @fy = fy
      @cx = cx
      @cy = cy
      @skew = skew
    end

    def k
      Matrix.rows [ [ @fx, @skew, @cx ], [ 0, @fy, @cy ], [0,0,1] ]
    end

    def dump( io )
      [ :fx, :fy, :cx, :cy, :skew ].each { |key|
        io.puts "  %10s:  %10f" % [key.to_s, send(key)]
      }
      io.puts "Camera projection matrix:"
      print_mat( k, io )
    end


    def self.from_xml( xml )
      Calibration.new( xml.fx.text.to_f, xml.fy.text.to_f, 
                      xml.cx.text.to_f, xml.cy.text.to_f,
                      xml.skew.text.to_f )
    end
  end

  class Resolution
    attr_reader :h, :w
    alias_method :height, :h
    alias_method :width, :w

    def initialize( w, h )
      @w = w
      @h = h
    end

    def self.from_xml( xml )
      w = xml.width
      h = xml.height
      Resolution.new( w, h )
    end
  end

  # "Transform" is the 3D homogeneous transform from camera to world.
  # That is, T * [0 0 0 1]^T (the origin of the camera frame)
  # yields the camera's position in world coordinate frame
  #
  # Or
  #
  # R  T
  # 0  1
  #
  class Transform
    attr_reader :mat

    def initialize( mat, opts = {} )
      @mat = case mat
             when Transform
               mat.mat
             else
               mat
             end
    end

    def r_mat
     Matrix.rows mat.to_a.first(3).map { |row| row.first(3) } 
    end

    def t_mat
      Vector[ *( mat.to_a.first(3).map { |row| row.at(3) } ) ]
    end

    def t
      t_mat
    end

    def inv
      Transform.new mat.inv
    end

    def *(b)
      mat * b
    end

   
    def dump( io = STDOUT )
      print_mat( mat, io )
    end

    def self.from_xml( xml, global = nil )
      m = xml.text.split(/\s/).map(&:to_f)
      raise "Not enough elements in matrix" unless m.length == 16

      arr = 4.times.map { m.shift(4) }

      if global
        IncrementalTransform.new( global.mat, Matrix.rows(arr) )
      else
        Transform.new( Matrix.rows( arr )  )
      end
    end
  end

  class IncrementalTransform < Transform
    def initialize( global, increment )
      @global = global
      @increment = increment
      super (@global * @increment)
    end

    def global; Transform.new @global; end
    def incremental; Transform.new @increment; end

    def dump( io = STDOUT )
      io.puts "Incremental transform:"
      io.puts "    increment:"
      print_mat( @increment )
      io.puts "    global:"
      print_mat( @global )
      io.puts "    total transform:"
      print_mat mat
    end
  end

  class Camera
    attr_reader :name, :resolution, :transform, :calibration

    def initialize(  label, resolution, calibration, transform )
      @name = label
      @resolution = resolution
      @calibration = calibration
      @transform = transform
    end

    alias_method :body_to_world, :transform

    def world_to_body
      transform.inv
    end

    def dump( io = STDOUT )
      io.puts "Camera \"#{name}\""
      io.puts "Resolution: %d x %d" % [resolution.width, resolution.height]
      io.puts "Calibration:"
      calibration.dump io
      
      io.puts "Body-to-world transform"
      body_to_world.dump( io )
    end



    def self.from_xml( xml, global )
      # Leverage Ox::Element's method_missing support
      res = Resolution.from_xml xml.resolution
      trans = Transform.from_xml xml.transform, global
      calib = Calibration.from_xml xml.calibration

      Camera.new( xml.label,  res, calib, trans )
    end
  end
end
