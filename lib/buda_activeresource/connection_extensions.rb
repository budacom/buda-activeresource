require_relative "./json_formatter"

module BudaActiveResource
  class ConnectionExtensions
    include JsonFormatter

    self.format = JsonFormatter.new(collection_name)

    cattr_accessor :static_headers
    self.static_headers = headers

    # --
    def self.headers
      new_headers = static_headers.clone
      new_headers["Content-Type"] = "application/json"
      new_headers["Accept"] = "application/json"
      new_headers["X-Agent-Id"] = agent_id unless agent_id.nil?
      new_headers
    end

    def self.retry_on_error(retries: 5, error_class: StandardError)
      retries -= 1
      yield
    rescue error_class
      retry unless retries.negative?
    end

    def self.connection(refresh: false)
      connection = super(refresh)
      _connection.set_secret(secret) unless secret.nil?
      connection
    end
  end
end
