module BudaActiveResource
  class Connection
    class Error < ::StandardError
      attr_reader :status, :details

      def initialize(_status, _details)
        super _status.to_s

        @status = _status
        @details = _details
      end
    end

    def initialize(_options = {})
      @site = _options.fetch(:site)
      @agent_id = _options.fetch(:agent_id)
      @agent_secret = _options.fetch(:agent_secret)
    end

    # ActiveResource::Connection implementation, headers are ignored for now.

    def get(_path, _headers = {})
      request(:get, _path)
    end

    def delete(_path, _headers = {})
      request(:delete, _path)
    end

    def patch(_path, _body = '', _headers = {})
      request(:patch, _path, _body.to_s)
    end

    def put(_path, _body = '', _headers = {})
      request(:put, _path, _body.to_s)
    end

    def post(_path, _body = '', _headers = {})
      request(:post, _path, _body.to_s)
    end

    def head(_path, _headers = {})
      request(:head, _path)
    end

    private

    def request(_method, _path, _body = nil)
      full_uri = URI.join(@site, _path)
      use_ssl = full_uri.scheme == 'https'

      response = Net::HTTP.start(full_uri.host, full_uri.port, use_ssl: use_ssl) do |http|
        # configure_http(http)
        request = Net::HTTP::const_get(_method.capitalize).new _path

        request['Accept'] = 'application/json'
        request['X-Agent-Id'] = @agent_id

        if _body
          request['Content-Type'] = 'application/json'
          request.body = _body
        end

        Authograph.signer.sign(request, @agent_secret) unless @agent_secret.nil?
        http.request(request)
      end

      process_error_response(response) unless response.is_a? Net::HTTPSuccess
      response
    end

    def process_error_response(_response)
      json_error = JSON.parse(_response.body) rescue nil # rubocop:disable Style/RescueModifier

      raise Error.new(_response.status.to_i, json_error || _response.body)
    end

    def connection
      @connection ||= Faraday.new
    end
  end
end
