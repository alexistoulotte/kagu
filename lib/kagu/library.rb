module Kagu

  class Library

    PATH = "#{ENV['HOME']}/Music/iTunes/iTunes Music Library.xml"

    attr_reader :path

    def initialize(path = PATH)
      self.path = path
    end

    def playlists
      Playlists.new(self)
    end

    def tracks
      Tracks.new(self)
    end

    private

    def path=(path)
      raise IOError.new("No such file: #{path.inspect}") unless File.file?(path)
      @path = path
    end

  end

end
