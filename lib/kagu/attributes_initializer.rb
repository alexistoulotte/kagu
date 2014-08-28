module AttributesInitializer

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to?("#{name}=", true)
    end
    self.class.const_get(:MANDATORY_ATTRIBUTES).each do |attribute|
      raise("#{self.class}##{attribute} is mandatory") if send(attribute).nil?
    end
  end

end
