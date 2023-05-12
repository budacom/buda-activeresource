module BudaActiveResource
  module Configuration
    # API_BASE_URL = "#{ENV['PATABIT_API_URL']}/api/v2/bo/"

    FIND_PER_PAGE = 300

    def api_base_url
      "#{ENV['PATABIT_API_URL']}/api/v2/bo/"
    end

    # def agent_id
    #   ENV['RESOURCES_API_AGENT_ID']
    # end

    # def secret
    #   ENV['RESOURCES_API_AGENT_SECRET']
    # end

    def agent_id
      ENV['PATABIT_AGENT_ID']
    end

    def secret
      ENV['PATABIT_AGENT_SECRET']
    end
  end
end