module Kagu

  class Tracks

    include Enumerable

    attr_reader :library

    def initialize(library)
      raise ArgumentError.new("#{self.class}#library must be a library, #{library.inspect} given") unless library.is_a?(Library)
      @library = library
    end

    def each(&block)
      return unless block_given?
      File.open(library.path, 'r') do |file|
        while !file.eof? && (line = file.readline.strip)
          next unless line.starts_with?('<key>Track ID</key>')
          attributes = {}
          begin
            match = line.match(/<key>(.+)<\/key><(\w+)>(.*)<\/\2>/)
            next unless match
            name = "itunes_#{match[1].downcase.gsub(' ', '_')}"
            value = match[3]
            attributes[name] = value
          end while (line = file.readline.strip) != '</dict>'
          yield(Track.new(attributes)) if attributes['itunes_track_type'] == 'File' && attributes['itunes_podcast'].blank?
        end
      end
    end

  end

end
