module BudaActiveResource
  module MoneyExtensions
    # RailsMoney support
    def self.monetize(*fields)
      options = fields.extract_options!
      fields.each { |field| monetize_field(field, options) }
    end

    def self.monetize_field(field, _options = {})
      # Getter
      define_method field do
        amount, currency = attributes[field.to_sym]
        Money.from_amount(amount.to_f, currency) if amount
      end
      # Setter
      define_method "#{field}=" do |new_amount|
        amount = new_amount.amount
        currency = new_amount.currency
        attributes[:amount] = [amount, currency].map(&:to_s)
      end
    end
  end
end
