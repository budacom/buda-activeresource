require 'buda_active_resource/railties/resource_api_mock/resource_api_mock'
require 'buda_active_resource/railties/resource_api_mock/mock_store'

class BudaActiveResource::Base
  include BudaActiveResource::ResourceApiMock
end

RSpec.configure do |config|
  config.before(:example) do |_example|
    BudaActiveResource::MockStore.drop
  end
end
