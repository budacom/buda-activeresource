module BudaActiveResource
  module ConnectionExtensions
    def set_secret(secret)
      @secret = secret
    end

    def request(method, path, *arguments)
      result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
        payload[:method]      = method
        payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
        Net::HTTP.start(site.host, site.port, use_ssl: defined? @ssl_options) do |http|
          configure_http(http)
          request = Net::HTTP::const_get(method.capitalize).new path
          headers = arguments.last
          headers.each do |key, value|
            request[key] = value
          end
          request.body = arguments.first if arguments.length > 1
          Authograph.signer.sign(request, @secret) if !@secret.nil?
          payload[:result] = http.request(request)
        end
      end
      handle_response(result)
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise SSLError.new(e.message)
    end
  end
end
