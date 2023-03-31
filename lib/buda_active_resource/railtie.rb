require_relative 'connection_patch'

module ActiveAdminResource
  class Railtie < Rails::Railtie
    initializer 'railtie.configure_rails_initialization' do
      ActiveResource::Connection.prepend(ConnectionExtensions)
    end
  end
end
