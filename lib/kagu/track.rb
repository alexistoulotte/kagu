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
      length <=> other.length
    end

    def ==(other)
      other.is_a?(self.class) && artist == other.artist && title == other.title
    end

    def eql?(other)
      super || self == other
    end

    def exists?
      File.file?(path)
    end

    def hash
      [artist, title].hash
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

    def length=(value)
      @length = value.to_s =~ /\A[0-9]+\z/ ? value.to_i : nil
    end

    def path=(value)
      @path = value.to_s.presence
      raise Error.new("No such file: #{path.inspect}") if File.exists?(path) && !exists?
      Kagu.logger.error('Kagu') { "No such track: #{path.inspect}" } unless exists?
    end

    def title=(value)
      @title = value.to_s.squish.presence
    end

    def xml_album=(value)
      self.album = html_entities_decode(value)
    end

    def xml_artist=(value)
      self.artist = html_entities_decode(value)
    end

    def xml_bpm=(value)
      self.bpm = value
    end

    def xml_date_added=(value)
      self.added_at = value.present? ? Time.parse(value.to_s) : nil
    end

    def xml_genre=(value)
      self.genre = html_entities_decode(value)
    end

    def xml_location=(value)
      path = CGI.unescape(html_entities_decode(value).gsub('+', '%2B')).gsub(/\Afile:\/\/(localhost)?/, '')
      path = path.encode('UTF-8', 'UTF-8-MAC') if IS_MAC_OS
      self.path = path
    end

    def xml_name=(value)
      self.title = html_entities_decode(value)
    end

    def xml_total_time=(value)
      self.length = value.to_s =~ /\A[0-9]+\z/ ? (value.to_i / 1000.0).round : nil
    end

    def xml_track_id=(value)
      self.id = value
    end

    def xml_year=(value)
      self.year = value
    end

    def year=(value)
      @year = value.to_s =~ /\A\d{,4}\z/ ? value.to_i : nil
    end

  end

end
