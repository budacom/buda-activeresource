require_relative 'lib/buda_active_resource/version'

Gem::Specification.new do |spec|
  spec.name        = 'buda_active_resource'
  spec.version     = BudaActiveResource::VERSION
  spec.summary     = 'pending'
  spec.description = 'pending'
  spec.authors     = ['devs@buda.com']
  spec.license     = 'MIT'

  spec.add_dependency 'activeadmin'
  spec.add_dependency 'activeresource'
  spec.add_dependency 'authograph'
  spec.add_dependency 'enumerize'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
end
