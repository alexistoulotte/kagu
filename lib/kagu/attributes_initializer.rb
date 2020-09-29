module Kagu

  module AttributesInitializer

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=", true)
      end
      self.class.const_get(:MANDATORY_ATTRIBUTES).each do |attribute|
        raise Error.new("#{self.class}##{attribute} is mandatory for #{inspect}") if send(attribute).nil?
      end
    end

  end

end
