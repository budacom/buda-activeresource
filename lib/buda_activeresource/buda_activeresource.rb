require 'configuration'

module BudaActiveResource
  def self.config
    @config ||= Configuration.new
  end

  def self.logger
    config.logger
  end

  def self.configure(_options = nil, &_block)
    config.assign_attributes(_options) unless _options.nil?
    _block.call(config) unless _block.nil?
  end
end
