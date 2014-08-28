module Kagu

  class Playlist

    MANDATORY_ATTRIBUTES = %w(name)

    include AttributesInitializer
    include Enumerable

    attr_reader :name, :tracks

    delegate :each, to: :tracks

    def to_s
      name
    end

    private

    def itunes_name=(value)
      @@html_entities ||= HTMLEntities.new
      self.name = @@html_entities.decode(value)
    end

    def name=(value)
      @name = value.to_s.squish.presence
    end

    def tracks=(values)
      @tracks = [values].flatten.select { |value| value.is_a?(Track) }
    end

  end

end
