module BudaActiveResource
  class Railtie < Rails::Railtie
    initializer 'railtie.configure_rails_initialization' do
      # ToDo: move to a utils module
      Enumerable.send(:define_method, 'and_preload') do |model_to_load|
        model_to_load = model_to_load.to_s.singularize
        klass_to_load = Object.const_get model_to_load.classify
        foreign_ids = map { |collection_item| collection_item.send("#{model_to_load}_id") }.uniq
        preloaded_items = if klass_to_load < ApplicationResource
                            # Class to load must support where(id: [])
                            klass_to_load.where(id: foreign_ids, per: foreign_ids.count)
                          elsif klass_to_load < ApplicationRecord
                            klass_to_load.where(id: foreign_ids)
                          else
                            raise "#{klass_to_load} is not from a supported preload type"
                          end
        each do |collection_item|
          corresponding_preloaded = preloaded_items.find do |pit|
            pit.id == collection_item.send("#{model_to_load}_id")
          end
          collection_item.send("#{model_to_load}=", corresponding_preloaded)
        end

        self
      end
    end
  end
end
