module Kagu

  class Track

    include AttributesInitializer
    include Comparable

    MANDATORY_ATTRIBUTES = %w(added_at id length path)

    attr_reader :added_at, :album, :artist, :bpm, :genre, :id, :length, :path, :title, :year

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
      path.file?
    end

    def hash
      [artist, title].hash
    end

    def relative_path(directory)
      directory = directory.to_s
      directory.present? ? Pathname.new(path.to_s.gsub(/\A#{Regexp.escape(directory)}\//, '')) : path
    end

    def to_s
      "#{artist} - #{title}"
    end

    private

    def added_at=(value)
      if value.is_a?(String)
        value = Time.parse(value)
      elsif value.is_a?(Integer)
        value = Time.at(value)
      end
      @added_at = value.is_a?(Time) ? value.utc : nil
    end

    def album=(value)
      @album = value.to_s.squish.presence
    end

    def artist=(value)
      @artist = value.to_s.squish.presence
    end

    def bpm=(value)
      value = value.to_s =~ /\A[0-9]+\z/ ? value.to_i : nil
      @bpm = (value && value > 0) ? value : nil
    end

    def genre=(value)
      @genre = value.to_s.squish.presence
    end

    def id=(value)
      @id = value.to_s.presence
    end

    def length=(value)
      @length = value.to_s =~ /\A[0-9]+\z/ ? value.to_i : nil
    end

    def path=(value)
      value = value.to_s.presence
      value = URI.unescape(URI.parse(value).path).presence if value.is_a?(String) && value.starts_with?('file://')
      value = value.encode('UTF-8', 'UTF-8-MAC') if value.present? && Kagu::IS_MAC_OS
      if value.present?
        @path = Pathname.new(value)
        raise Error.new("No such file: #{path.to_s.inspect}") if path.exist? && !exists?
        Kagu.logger.error('Kagu') { "No such track: #{path.inspect}" } unless exists?
      else
        @path = nil
      end
    end

    def title=(value)
      @title = value.to_s.squish.presence
    end

    def year=(value)
      @year = value.to_s =~ /\A\d{,4}\z/ ? value.to_i : nil
    end

  end

end
