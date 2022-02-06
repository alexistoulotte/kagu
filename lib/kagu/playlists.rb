module Kagu

  class Playlists

    include Enumerable

    def build(attributes = {})
      Playlist.new(attributes)
    end

    def create(attributes = {})
      build(attributes).tap(&:save)
    end

    def each
      return unless block_given?
      Kagu.logger.debug('Kagu') { 'Loading library playlists' }
      tracks = {}.tap do |items|
        Tracks.new.each { |track| items[track.id] = track }
      end
      playlist_name = nil
      playlist_tracks = []
      SwiftHelper.execute("
        import iTunesLibrary

        let library = try! ITLibrary(apiVersion: \"1\")
        for playlist in library.allPlaylists.filter({ !$0.isMaster }) {
          print(\"BEGIN_PLAYLIST\")
          print(playlist.name)
          for track in playlist.items.filter({ $0.mediaKind == ITLibMediaItemMediaKind.kindSong }) {
            print(String(track.persistentID.uint64Value, radix: 16).uppercased())
          }
          print(\"END_PLAYLIST\")
        }
      ").each do |line|
        if line == 'BEGIN_PLAYLIST'
          playlist_name = nil
          playlist_tracks = []
        elsif line == 'END_PLAYLIST'
          yield(Playlist.new(name: playlist_name, tracks: playlist_tracks)) if playlist_name.present?
        elsif playlist_name.nil?
          playlist_name = line
        else
          playlist_tracks << tracks[line]
        end
      end
      nil
    end

  end

end
