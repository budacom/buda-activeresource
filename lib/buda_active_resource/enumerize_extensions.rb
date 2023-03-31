module BudaActiveResource
  module EnumerizeExtensions
    # Enumerize support
    extend Enumerize if defined? Enumerize

    def enumerize(name, options = {})
      # Getter
      define_method name do
        enumerize_attr = self.class.send(name)
        Enumerize::Value.new(enumerize_attr, attributes[name.to_sym])
      end

      # Setter
      define_method "#{name}=" do |value|
        enumerize_attr = self.class.send(name)
        raise ArgumentError.new "Invalid value '#{value}' for #{name}" unless value.to_s.in? enumerize_attr.values

        attributes[name.to_sym] = value
      end
      super
    end
  end
end
