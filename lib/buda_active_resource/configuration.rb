class Configuration
  attr_accessor :agent_id, :secret, :agent_id, :secret, :api_base_url

  # API_BASE_URL = "#{ENV['PATABIT_API_URL']}/api/v2/bo/"

  FIND_PER_PAGE = 300

  def self.agent_id
    ENV['RESOURCES_API_AGENT_ID']
  end

  def self.secret
    ENV['RESOURCES_API_AGENT_SECRET']
  end

  def self.agent_id
    ENV['PATABIT_AGENT_ID']
  end

  def self.secret
    ENV['PATABIT_AGENT_SECRET']
  end
end
