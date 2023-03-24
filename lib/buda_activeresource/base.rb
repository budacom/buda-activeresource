class Base < ActiveResource::Base
  include EnumerizeExtensions
  include MoneyExtensions
  include ConnectionPatch # source: app/lib/active_admin_resource/connection_extensions.rb

  def created_at
    Time.parse(attributes[:created_at].to_s).in_time_zone if attributes[:created_at].present?
  end

  def updated_at
    Time.parse(attributes[:updated_at].to_s).in_time_zone if attributes[:updated_at].present?
  end

  # lo usa la gema de IA
  def to_global_id
    URI::GID.build(['patabit', model_name.name, id, {}])
  end

  def self.polymorphic_name
    base_class.name
  end

  def self.confirmed
    where(state: 'confirmed')
  end

  def self.inherited(model)
    model.site = API_BASE_URL
    super
  end

  def self.find_by(arg, *_args)
    find(arg[primary_key])
  end

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
