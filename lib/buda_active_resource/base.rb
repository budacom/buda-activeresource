module BudaActiveResource
  class Base < ::ActiveResource::Base
    FIND_PER_PAGE = 100

    class << self
      threadsafe_attribute :_buda_site, :_agent_id, :_agent_secret

      def connection(_refresh = false)
        return superclass.connection if !_buda_site_defined?

        self._connection = nil if _refresh
        self._connection ||= BudaActiveResource::Connection.new(
          site: _buda_site,
          agent_id: _agent_id,
          agent_secret: _agent_secret
        )
      end

      def site=(_value)
        self._buda_site = URI.parse(_value)
        self._connection = nil
      end

      def agent_id=(_value)
        self._agent_id = _value
        self._connection = nil
      end

      def agent_secret=(_value)
        self._agent_secret = _value
        self._connection = nil
      end

      def site
        return _buda_site if _buda_site_defined?

        superclass.site
      end
    end

    self.format = JsonFormatter.new(collection_name)

    include Extensions::Associations
    include Extensions::ActiveAdminResource
    include Extensions::Money
    include Extensions::Enumerize

    def created_at
      Time.parse(attributes[:created_at].to_s).in_time_zone if attributes[:created_at].present?
    end

    def updated_at
      Time.parse(attributes[:updated_at].to_s).in_time_zone if attributes[:updated_at].present?
    end

    def to_global_id
      URI::GID.build(['patabit', model_name.name, id, {}])
    end

    def self.polymorphic_name
      base_class.name
    end

    def self.find_by(arg, *_args)
      find(arg[primary_key])
    end

    def self.find_each(params = {}, &block) # rubocop:disable Metrics/MethodLength
      return enum_for(__method__, params) unless block

      page = 1

      loop do
        result = retry_on_error error_class: Net::ReadTimeout do
          find(
            :all, params: {
              page: page,
              per: FIND_PER_PAGE
            }.merge(params)
          )
        end

        pagination_info = format.pagination_info

        result.each(&block)

        break if pagination_info['total_pages'] <= page

        page += 1
      end
    end

    def self.retry_on_error(retries: 5, error_class: StandardError)
      retries -= 1
      yield
    rescue error_class
      retry unless retries.negative?
    end
  end
end
