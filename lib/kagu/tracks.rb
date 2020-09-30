module Kagu

  class Tracks

    include Enumerable

    EXTENSIONS = %w(.aac .flac .mp3 .wav).freeze

    def each(&block)
      return unless block_given?
      Kagu.logger.debug('Kagu') { 'Loading library tracks' }
      attributes = {}
      SwiftHelper.execute(%Q{
        import iTunesLibrary

        func printObjectProperty<T: Encodable>(name: String, value: T?) {
          let jsonEncoder = JSONEncoder()
          let jsonData = try! jsonEncoder.encode(value)
          let json = String(data: jsonData, encoding: String.Encoding.utf8)
          print("\\(name)=\\(json!)")
        }

        let library = try! ITLibrary(apiVersion: "1")
        for track in library.allMediaItems.filter({ $0.mediaKind == ITLibMediaItemMediaKind.kindSong }) {
          print("BEGIN_TRACK")
          printObjectProperty(name: "added_at", value: track.addedDate!.timeIntervalSince1970)
          printObjectProperty(name: "album", value: track.album.title)
          printObjectProperty(name: "artist", value: track.artist!.name)
          printObjectProperty(name: "bpm", value: track.beatsPerMinute)
          printObjectProperty(name: "genre", value: track.genre)
          printObjectProperty(name: "id", value: String(track.persistentID.uint64Value, radix: 16).uppercased())
          printObjectProperty(name: "length", value: track.totalTime)
          printObjectProperty(name: "path", value: track.location)
          printObjectProperty(name: "title", value: track.title)
          printObjectProperty(name: "year", value: track.year)
          print("END_TRACK")
        }
      }).each do |line|
        if line == 'BEGIN_TRACK'
          attributes = {}
        elsif line == 'END_TRACK'
          yield(Track.new(attributes))
        elsif match = /(^\w+)=(.*)/.match(line)
          attributes[match[1]] = JSON.parse(match[2])
        end
      end
      nil
    end

  end

end
