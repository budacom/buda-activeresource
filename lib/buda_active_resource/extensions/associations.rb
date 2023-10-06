require 'activeresource'

module BudaActiveResource
  module Extensions
    module Associations
      extend ActiveSupport::Concern

      class_methods do
        def scope(name, body)
          singleton_class.send(:define_method, name, &body)
          ActiveResource::Collection.send(:define_method, name, &body)
        end

        def has_many(plural_model_name, options = {})
          klass = Object.const_get plural_model_name.to_s.singularize.classify

          # Getter
          define_method plural_model_name do
            var = instance_variable_get("@#{plural_model_name}")
            next var if var.present?

            collection = if options[:as] # polymorphic
                           foreign_key = "#{options[:as]}_id"
                           foreign_type = "#{options[:as]}_type"
                           klass.where(foreign_type => model_name.name, foreign_key => id)
                         else
                           foreign_key = "#{model_name.name.downcase}_id"
                           klass.where(foreign_key => id)
                         end

            instance_variable_set("@#{plural_model_name}", collection)
          end

          # Setter
          define_method "#{plural_model_name}=" do |value|
            instance_variable_set("@#{plural_model_name}", value)
          end
        end

        def has_one(model_name)
          klass = Object.const_get model_name.to_s.classify
          # Getter
          define_method model_name do
            var = instance_variable_get("@#{model_name}")
            attr = self&.attributes[model_name].presence
            if !var.nil?
              var
            elsif !attr.nil?
              attr
            else
              foreign_key = "#{self.class.name.underscore}_id"
              instance_variable_set("@#{model_name}", klass.find_by(foreign_key => id))
            end
          end
          # Setter
          define_method "#{model_name}=" do |value|
            instance_variable_set("@#{model_name}", value)
          end
        end
      end
    end
  end
end
