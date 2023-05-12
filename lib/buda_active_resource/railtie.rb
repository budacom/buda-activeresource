require_relative 'connection_patch'

module BudaActiveResource
  class Railtie < Rails::Railtie
    initializer 'railtie.configure_rails_initialization' do
      ActiveResource::Connection.prepend(ConnectionPatch)
    end
  end
end
