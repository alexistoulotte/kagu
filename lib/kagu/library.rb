module Kagu

  class Library

    def finder(options = {})
      Finder.new(options)
    end

    def playlists
      Playlists.new
    end

    def tracks
      Tracks.new
    end

  end

end
