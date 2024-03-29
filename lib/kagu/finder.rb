module Kagu

  class Finder

    MANDATORY_ATTRIBUTES = [].freeze

    delegate :replace, :transliterate, to: 'self.class'

    def self.replace(value, replacements = {})
      replaced = value.to_s.dup
      replacements.each do |pattern, replacement|
        replaced.gsub!(pattern, replacement)
      end
      replaced.presence
    end

    def self.transliterate(value)
      ActiveSupport::Inflector.transliterate(value.to_s).squish.downcase.presence
    end

    def initialize(options = {})
      @semaphore = Mutex.new
      reload(options)
    end

    def find(attributes = {})
      attributes.stringify_keys!
      results = [].tap do |matches|
        tracks_digests.each_with_index do |hash, digests_index|
          digests(attributes).each_with_index do |digest, digest_index|
            tracks = hash[digest].presence || next
            tracks = tracks.reject { |track| matches.any? { |match| match.try(:include?, track) } }
            next if tracks.empty?
            index = [digests_index, digest_index].max
            matches[index] ||= []
            matches[index].push(*tracks)
          end
        end
      end
      results.compact!
      replacements.any? ? results : results.flatten
    end

    def ignored
      @ignored ||= []
    end

    def ignored?(track)
      track.present? && digests(track).any? { |digest| ignored.include?(digest) }
    end

    def reload(options = {})
      @ignored = nil
      @replacements = nil
      @tracks_digests = nil
      options.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=", true)
      end
      self
    end

    def reload!(options = {})
      @tracks = nil
      reload(options)
    end

    def replacements
      @replacements ||= []
    end

    private

    def digests(attributes)
      attributes = { 'artist' => attributes.artist, 'title' => attributes.title } unless attributes.is_a?(Hash)
      attributes.stringify_keys!
      return [] if attributes['artist'].blank? || attributes['title'].blank?
      digests = [transliterate("#{attributes['artist']} #{attributes['title']}")]
      replacements.each do |item|
        digests << replace(digests.last, item)
      end
      digests.uniq
    end

    def ignored=(values)
      @ignored = [values].flatten.map do |value|
        case value
        when Hash
          value = value.stringify_keys
          value = "#{value['artist']} #{value['title']}"
        when Track
          value = "#{value.artist} #{value.title}"
        else
          value = value.to_s
        end
        self.class.transliterate(value)
      end.compact.uniq
    end

    def replacements=(value)
      if value.nil?
        @replacements = []
      elsif value.is_a?(Hash)
        @replacements = [value]
      elsif value.is_a?(Array)
        @replacements = value
      else
        raise("Replacements must be an array or a hash, #{value.inspect} given")
      end
      replacements.each do |item|
        raise('Replacements must contain only hashes or arrays') unless item.is_a?(Hash) || item.is_a?(Array)
      end
    end

    def tracks
      @semaphore.synchronize do
        unless @tracks
          @tracks = Tracks.new.to_a
          Kagu.logger.debug('Kagu') { "Loaded #{@tracks.size} track(s) from library" }
        end
        @tracks
      end
    end

    def tracks_digests
      @tracks_digests ||= begin
        [].tap do |tracks_digests|
          tracks.each do |track|
            digests = digests(track)
            next if digests.any? { |digest| ignored.include?(digest) }
            digests.each_with_index do |digest, index|
              tracks_digests[index] ||= {}
              tracks_digests[index][digest] ||= []
              tracks_digests[index][digest].push(track)
            end
          end
        end
      end
    end

  end

end
