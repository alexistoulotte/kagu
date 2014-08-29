module Kagu

  class Playlists

    include Enumerable

    attr_reader :library

    def initialize(library)
      raise ArgumentError.new("#{self.class}#library must be a library, #{library.inspect} given") unless library.is_a?(Library)
      @library = library
    end

    def create(attributes = {})
      Playlist.new(attributes).save
    end

    def each(&block)
      return unless block_given?
      tracks = {}.tap do |tracks|
        library.tracks.each { |track| tracks[track.id] = track }
      end
      File.open(library.path, 'r') do |file|
        begin
          line = file.readline.strip
        end while !line.starts_with?('<key>Playlists</key>')
        playlist_name = nil
        playlist_tracks = []
        while !file.eof? && (line = file.readline.strip)
          if line == '<key>Master</key><true/>'
            playlist_name = nil
            next
          elsif line == '</array>'
            yield(Playlist.new(itunes_name: playlist_name, tracks: playlist_tracks)) if playlist_name.present?
            playlist_name = nil
            playlist_tracks = []
            next
          end
          match = line.match(/<key>(.+)<\/key><(\w+)>(.*)<\/\2>/)
          next unless match
          name = match[1]
          value = match[3]
          if name == 'Name'
            playlist_name = value
          elsif name == 'Track ID'
            playlist_tracks << tracks[value.to_i]
          end
        end
      end
    end

  end

end
