module BudaActiveResource
  module Extensions
    module Enumerize
      extend ActiveSupport::Concern

      class_methods do
        def enumerized_attributes
          @enumerized_attributes ||= ::Enumerize::AttributeMap.new
        end

        def enumerize(name, options = {})
          attr = ::Enumerize::Attribute.new(self, name, options)
          enumerized_attributes << attr

          define_singleton_method name do
            enumerized_attributes[attr.name.to_sym]
          end

          define_method name do
            enumerize_attr = self.class.send(name)
            ::Enumerize::Value.new(enumerize_attr, attributes[name.to_sym])
          end

          define_method "#{name}=" do |value|
            enumerize_attr = self.class.send(name)

            unless value.to_s.in? enumerize_attr.values
              raise ArgumentError.new "Invalid value '#{value}' for #{name}"
            end

            attributes[name.to_sym] = value
          end
        end
      end
    end
  end
end
