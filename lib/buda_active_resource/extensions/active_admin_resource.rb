module BudaActiveResource
  module Extensions
    module ActiveAdminResource
      extend ActiveSupport::Concern

      class_methods do
        def process_active_admin_resource_query(_id)
          find(_id)
        end

        def process_active_admin_collection_query(options = {}, **kwargs)
          options = options.merge(kwargs)

          collection = find(
            :all,
            params: {
              search: options[:ransack] || {},
              order: options[:reorder],
              page: options[:page],
              per: options[:per]
            }
          )

          ::ActiveAdminResource::QueryResult.new(
            collection,
            format.pagination_info['total_count'],
            format.pagination_info['current_page']
          )
        end
      end
    end
  end
end
