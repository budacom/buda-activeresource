module BudaActiveResource
  class MockStore
    @@store_hash = Hash.new([])

    def self.select(model, query_params)
      query_params.stringify_keys!
      query_params.dup.each do |k, v|
        if query_params["#{k}_id"].nil? && v.respond_to?(:id)
          query_params["#{k}_id"] = v.id
          query_params.delete(k)
        end
      end
      store_for_model(model).select do |obj|
        obj.attributes.slice(*query_params.keys) == query_params
      end
    end

    def self.insert(object)
      model = object_to_model(object)
      object.id ||= next_id(model)
      @@store_hash[model] += [object]
    end

    def self.update(object)
      stored_object = store_for_object(object).find { |i| i.id == object.id }
      raise "Object Not Found: #{object.class} ##{object.id}" unless stored_object
      store_for_object(object).delete(stored_object)
      insert(object)
    end

    def self.delete(object)
      store_for_object(object).delete(object) ||
        raise("Object Not Found: #{object.class} ##{object.id}")
    end

    def self.drop
      @@store_hash = Hash.new([])
    end

    def self.object_to_model(object)
      object.class.name.downcase.to_sym
    end

    def self.store_for_object(object)
      store_for_model object_to_model(object)
    end

    def self.store_for_model(model)
      @@store_hash[model]
    end

    def self.next_id(model)
      (store_for_model(model).map(&:id).max || 0) + 1
    end
  end
end
