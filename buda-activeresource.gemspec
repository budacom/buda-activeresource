Gem::Specification.new do |spec|
  spec.name        = 'buda-activeresource'
  spec.version     = '1.0.0'
  spec.date        = '2023-03-03'
  spec.summary     = "" #"ActiveResource for ActiveAdmin"
  spec.description = "" # "An adapter for using ActiveResource with ActiveAdmin"
  spec.authors       = ["devs@buda.com"]
  spec.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # spec.homepage    = "https://github.com/budacom/activeadmin_resource"
  spec.license     = 'MIT'

  spec.add_dependency 'activeadmin'
  spec.add_dependency 'activeresource'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
end
