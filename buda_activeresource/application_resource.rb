class ApplicationResource < ActiveResource::Base
  # extend ActiveAdminResource::Associations
  extend Enumerize if defined? Enumerize
  # extend ActiveAdminResource::GemAdaptors::EnumerizeAdaptor
  # extend ActiveAdminResource::GemAdaptors::MoneyAdaptor

  # TODO: move class to separate file
  class JsonFormatter
    include ActiveResource::Formats::JsonFormat

    attr_reader :collection_name
    attr_reader :pagination_info

    def initialize(collection_name)
      @collection_name = collection_name.to_s
    end

    def decode(json)
      pre_process(ActiveSupport::JSON.decode(json))
    end

    private

    def pre_process(data)
      @pagination_info = data['meta']
      data.delete('meta')
      if data.is_a?(Hash) && data.keys.size == 1 && data.values.first.is_a?(Enumerable)
        data.values.first
      elsif data.is_a?(Array) && data.size == 1
        data.first
      else
        data
      end
    end
  end

  self.format = JsonFormatter.new(collection_name)

  cattr_accessor :static_headers
  self.static_headers = headers

  def self.inherited(model)
    model.site = ENV['RESOURCES_API_URL'] if ENV.has_key?('RESOURCES_API_URL')
    super
  end

  def self.agent_id
    ENV['RESOURCES_API_AGENT_ID']
  end

  def self.secret
    ENV['RESOURCES_API_AGENT_SECRET']
  end

  def self.scope(name, body)
    singleton_class.send(:define_method, name, &body)
    # TODO: fix that a 2nd scope defined with same name in another model will override the 1st one,
    # as all model's collections inherit from ActiveResource::Collection
    ActiveResource::Collection.send(:define_method, name, &body)
  end

  def self.headers
    new_headers = static_headers.clone
    new_headers["Content-Type"] = "application/json"
    new_headers["Accept"] = "application/json"
    new_headers["X-Agent-Id"] = agent_id if !agent_id.nil?
    new_headers
  end

  def self.find_by(arg, *_args)
    find(arg[primary_key])
  end

  class << self
    def connection(refresh = false)
      connection = super(refresh)
      _connection.set_secret(secret) if !secret.nil?
      connection
    end
  end

  API_BASE_URL = "#{ENV['PATABIT_API_URL']}/api/v2/bo/"

  FIND_PER_PAGE = 300

  def self.inherited(model)
    model.site = API_BASE_URL
    super
  end

  def self.agent_id
    ENV['PATABIT_AGENT_ID']
  end

  def self.secret
    ENV['PATABIT_AGENT_SECRET']
  end

  def self.confirmed
    where(state: 'confirmed')
  end

  # def self.find_each(params = {})
  #   page = 1

  #   loop do
  #     result = retry_on_error error_class: Net::ReadTimeout do
  #       find(:all, params: {
  #         page: page,
  #         per: FIND_PER_PAGE
  #       }.merge(params))
  #     end

  #     pagination_info = format.pagination_info

  #     result.each do |account|
  #       yield account
  #     end

  #     break if pagination_info['total_pages'] <= page
  #     page += 1
  #   end
  # end

  def self.retry_on_error(retries: 5, error_class: StandardError)
    retries -= 1
    yield
  rescue error_class
    retry unless retries.negative?
  end

  def self.scope(name, body)
    singleton_class.send(:define_method, name, &body)
    ActiveResource::Collection.send(:define_method, name, &body)
  end

  def self.has_many(plural_model_name, options = {})
    klass = Object.const_get plural_model_name.to_s.singularize.classify
    # Getter
    define_method plural_model_name do
      var = instance_variable_get("@#{plural_model_name}")
      if !var.nil?
        var
      else
        collection = if options[:as] # polymorphic
                       foreign_key = "#{options[:as]}_id"
                       foreign_type = "#{options[:as]}_type"
                       klass.where(foreign_type => model_name.name, foreign_key => id)
                     else
                       foreign_key = "#{model_name.name.downcase}_id"
                       klass.where(foreign_key => id)
                     end
        instance_variable_set("@#{plural_model_name}", collection)
      end
    end
    # Setter
    define_method "#{plural_model_name}=" do |value|
      instance_variable_set("@#{plural_model_name}", value)
    end
  end

  def self.has_one(model_name)
    klass = Object.const_get model_name.to_s.classify
    # Getter
    define_method model_name do
      var = instance_variable_get("@#{model_name}")
      attr = self&.attributes[model_name].presence
      if !var.nil?
        var
      elsif !attr.nil?
        attr
      else
        foreign_key = "#{self.class.name.underscore}_id"
        instance_variable_set("@#{model_name}", klass.find_by(foreign_key => id))
      end
    end
    # Setter
    define_method "#{model_name}=" do |value|
      instance_variable_set("@#{model_name}", value)
    end
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

  # Enumerize support
  extend Enumerize

  def self.enumerize(name, options = {})
    # Getter
    define_method name do
      enumerize_attr = self.class.send(name)
      Enumerize::Value.new(enumerize_attr, attributes[name.to_sym])
    end
    # Setter
    define_method "#{name}=" do |value|
      enumerize_attr = self.class.send(name)
      raise ArgumentError.new "Invalid value '#{value}' for #{name}" unless value.to_s.in? enumerize_attr.values
      attributes[name.to_sym] = value
    end
    super
  end

  # RailsMoney support
  def self.monetize(*fields)
    options = fields.extract_options!
    fields.each { |field| monetize_field(field, options) }
  end

  def self.monetize_field(field, _options = {})
    # Getter
    define_method field do
      amount, currency = attributes[field.to_sym]
      Money.from_amount(amount.to_f, currency) if amount
    end
    # Setter
    define_method "#{field}=" do |new_amount|
      amount = new_amount.amount
      currency = new_amount.currency
      attributes[:amount] = [amount, currency].map(&:to_s)
    end
  end

  def self.polymorphic_name
    base_class.name
  end
end
