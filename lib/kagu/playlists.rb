module Kagu

  class Playlists

    include Enumerable

    attr_reader :library

    def initialize(library)
      raise ArgumentError.new("#{self.class}#library must be a library, #{library.inspect} given") unless library.is_a?(Library)
      @library = library
    end

    def build(attributes = {})
      Playlist.new(attributes)
    end

    def create(attributes = {})
      build(attributes).tap(&:save)
    end

    def each(&block)
      return unless block_given?
      tracks = {}.tap do |tracks|
        library.tracks.each { |track| tracks[track.id] = track }
      end
      Kagu.logger.debug('Kagu') { "Reading library playlists from #{library.path.inspect}" }
      File.open(library.path, 'r') do |file|
        begin
          line = file.readline.strip
        end while !line.starts_with?('<key>Playlists</key>')
        playlist_name = nil
        playlist_tracks = []
        skip_next = false
        while !file.eof? && (line = file.readline.strip)
          if line == '<key>Master</key><true/>'
            playlist_name = nil
            skip_next = true
            next
          end
          if line == '</array>'
            yield(Playlist.new(tracks: playlist_tracks, xml_name: playlist_name)) if playlist_name.present? && playlist_tracks.any?
            playlist_name = nil
            playlist_tracks = []
            next
          end
          match = line.match(/<key>(.+)<\/key><(\w+)>(.*)<\/\2>/)
          next unless match
          name = match[1]
          value = match[3]
          if name == 'Name'
            if skip_next
              skip_next = false
            else
              playlist_name = value
            end
          elsif name == 'Track ID'
            playlist_tracks << tracks[value.to_i]
          end
        end
      end
    end

  end

end
