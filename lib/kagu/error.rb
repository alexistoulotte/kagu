module Kagu

  class Error < StandardError

    attr_reader :original

    def initialize(message)
      @original = message.is_a?(Exception) ? message : nil
      message = original.message if original.is_a?(Exception)
      super(message.to_s.squish.presence)
    end

  end

end
