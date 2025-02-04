module BudaActiveResource
  module Extensions
    module Money
      extend ActiveSupport::Concern

      module ClassMethods
        def monetize(*fields)
          options = fields.extract_options!
          fields.each { |field| monetize_field(field, options) }
        end

        def monetize_field(field, _options = {})
          define_method field do
            amount, currency = attributes[field.to_sym]
            ::Money.from_amount(amount.to_f, currency) if amount
          end

          define_method :"#{field}=" do |amount|
            attributes[field.to_sym] = amount.presence && [amount.amount, amount.currency.iso_code]
          end
        end
      end

      included do
        extend ClassMethods if defined? ::Money
      end
    end
  end
end
