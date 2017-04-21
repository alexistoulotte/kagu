module Kagu

  class Track

    include AttributesInitializer
    include Comparable

    MANDATORY_ATTRIBUTES = %w(added_at id length path)
    IS_MAC_OS = RUBY_PLATFORM =~ /darwin/

    attr_reader :added_at, :album, :artist, :bpm, :genre, :id, :length, :path, :title, :year

    def initialize(attributes = {})
      super
    end

    def <=>(other)
      return nil unless other.is_a?(self.class)
      added_at <=> other.added_at
    end

    def ==(other)
      other.is_a?(self.class) && artist == other.artist && title == other.title && (length.to_i - other.length.to_i).abs < 3
    end

    def eql?(other)
      super || self == other
    end

    def exists?
      File.file?(path)
    end

    def relative_path(directory)
      directory.present? && directory.starts_with?(directory) ? path.gsub(/\A#{Regexp.escape(directory)}\//, '') : path
    end

    def to_s
      "#{artist} - #{title}"
    end

    private

    def added_at=(value)
      @added_at = value.is_a?(Time) ? value.utc : nil
    end

    def album=(value)
      @album = value.to_s.squish.presence
    end

    def artist=(value)
      @artist = value.to_s.squish.presence
    end

    def bpm=(value)
      @bpm = value.to_s =~ /\A[0-9]+\z/ ? value.to_i : nil
    end

    def genre=(value)
      @genre = value.to_s.squish.presence
    end

    def html_entities_decode(value)
      @@html_entities ||= HTMLEntities.new
      @@html_entities.decode(value.to_s)
    end

    def id=(value)
      @id = value.to_s =~ /\A[0-9]+\z/ ? value.to_i : nil
    end

    def itunes_album=(value)
      self.album = html_entities_decode(value)
    end

    def itunes_artist=(value)
      self.artist = html_entities_decode(value)
    end

    def itunes_bpm=(value)
      self.bpm = value
    end

    def itunes_date_added=(value)
      self.added_at = value.present? ? Time.parse(value.to_s) : nil
    end

    def itunes_genre=(value)
      self.genre = html_entities_decode(value)
    end

    def itunes_location=(value)
      path = CGI.unescape(html_entities_decode(value).gsub('+', '%2B')).gsub(/\Afile:\/\/(localhost)?/, '')
      path = path.encode('UTF-8', 'UTF-8-MAC') if IS_MAC_OS
      self.path = path
    end

    def itunes_name=(value)
      self.title = html_entities_decode(value)
    end

    def itunes_total_time=(value)
      self.length = value.to_s =~ /\A[0-9]+\z/ ? (value.to_i / 1000.0).round : nil
    end

    def itunes_track_id=(value)
      self.id = value
    end

    def itunes_year=(value)
      self.year = value
    end

    def length=(value)
      @length = value.to_s =~ /\A[0-9]+\z/ ? value.to_i : nil
    end

    def path=(value)
      @path = value.to_s.presence
      raise Error.new("No such file: #{path.inspect}") if File.exists?(path) && !exists?
      Kagu.logger.error('Kagu') { "No such iTunes track: #{path.inspect}" } unless exists?
    end

    def title=(value)
      @title = value.to_s.squish.presence
    end

    def year=(value)
      @year = value.to_s =~ /\A\d{,4}\z/ ? value.to_i : nil
    end

  end

end
