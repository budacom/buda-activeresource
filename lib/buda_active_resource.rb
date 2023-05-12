require 'activeresource'
require 'buda_active_resource/configuration'
require 'buda_active_resource/base'
require 'buda_active_resource/railtie'

module BudaActiveResource
  def self.config
    @config ||= Configuration.new
  end

  def self.logger
    config.logger
  end

  def self.configure(_options = nil, &_block)
    config.assign_attributes(_options) unless _options.nil?
    _block&.call(config)
  end
end
