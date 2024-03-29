module Kagu

  class Playlist

    MANDATORY_ATTRIBUTES = %w(name).freeze

    include AttributesInitializer
    include Enumerable

    attr_reader :name

    delegate :each, to: :tracks

    def save
      create
      clear
      add_tracks
    end

    def to_s
      name
    end

    def tracks
      @tracks ||= []
    end

    private

    def add_tracks
      return if tracks.empty?
      Kagu.logger.info('Kagu') { "Adding #{tracks.size} track(s) to playlist #{name.inspect}" }
      tracks.map(&:id).each_slice(500) do |ids|
        AppleScript.execute("
          tell application #{Kagu::OSX_APP_NAME.inspect}
            set playlistToPush to user playlist #{name.inspect}
            set idsToAdd to {#{ids.map(&:inspect).join(',')}}
            repeat with idToAdd in idsToAdd
              duplicate (tracks of library playlist 1 whose persistent ID is idToAdd) to playlistToPush
            end repeat
          end tell
        ")
      end
      true
    rescue => e
      raise Error.new(e)
    end

    def clear
      Kagu.logger.info('Kagu') { "Removing all tracks from playlist #{name.inspect}" }
      AppleScript.execute("
        tell application #{Kagu::OSX_APP_NAME.inspect}
          delete tracks of playlist #{name.inspect}
        end tell
      ")
      true
    rescue => e
      raise Error.new(e)
    end

    def create
      Kagu.logger.info('Kagu') { "Creating playlist #{name.inspect}" }
      AppleScript.execute("
        tell application #{Kagu::OSX_APP_NAME.inspect}
          if not (exists user playlist #{name.inspect}) then
            make new user playlist with properties { name: #{name.inspect} }
          end if
        end tell
      ")
      true
    rescue => e
      raise Error.new(e)
    end

    def name=(value)
      @name = value.to_s.squish.presence
    end

    def tracks=(values)
      @tracks = [values].flatten.select { |value| value.is_a?(Track) }
    end

  end

end
