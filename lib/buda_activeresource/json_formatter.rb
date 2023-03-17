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
