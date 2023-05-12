
require 'activeresource'

module BudaActiveResource
  module ConnectionExtensions
    extend ActiveSupport::Concern

    class_methods do
      def api_base_url
        "#{ENV['PATABIT_API_URL']}/api/v2/bo/"
      end

      def agent_id
        ENV['PATABIT_AGENT_ID']
      end

      def secret
        ENV['PATABIT_AGENT_SECRET']
      end

      def headers
        new_headers = static_headers.clone
        new_headers['Content-Type'] = 'application/json'
        new_headers['Accept'] = 'application/json'
        new_headers['X-Agent-Id'] = agent_id unless agent_id.nil?
        new_headers
      end

      def retry_on_error(retries: 5, error_class: StandardError)
        retries -= 1
        yield
      rescue error_class
        retry unless retries.negative?
      end

      def connection(refresh: false)
        connection = super(refresh)
        _connection.set_secret(secret) unless secret.nil?
        connection
      end
    end
  end
end
