require 'active_resource'
require 'uri'

module BudaActiveResource
  module ResourceApiMock
    def  self.included(klass)
      klass.extend ClassMethods
      klass.site = 'resource.api.mocked'
    end

    def site
      URI.parse('resource.api.mocked')
    end

    def create
      @persisted = true
      MockStore.insert(self)
    end

    def update
      MockStore.update(self)
    end

    def destroy
      MockStore.delete(self)
    end

    module ClassMethods
      def find_every(options)
        options = options[:params] if options.has_key? :params
        model = model_name.singular.to_sym
        MockStore.select(model, options)
      end

      def find_single(id, options)
        options = options[:params] if options.has_key? :params
        model = model_name.singular.to_sym
        MockStore.select(model, options.merge(id: id.to_i)).first
      end
    end
  end
end
