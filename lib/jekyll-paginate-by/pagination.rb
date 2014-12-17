module Jekyll
  module PaginateBy
    class Pagination < Generator
      attr_reader :site
      PAGINATION_DISABLED = 'Pagination is enabled, but I couldn\'t find an layout page to use as the pagination template, please site.\'paginate_by\' in config. Skipping pagination.'

      # This generator is safe from arbitrary code execution.
      safe true

      # This generator should be passive with regard to its execution
      priority :lowest

      # Generate paginated pages if necessary.
      #
      # site - The Site.
      #
      # Returns nothing.

      def generate(site)
        if Pager.pagination_enabled?(site)
          if configs = site.config['paginate_by']
            Pagination.parse_config(configs).each do |config|
              site.pages += PaginationGenerator.new(config, site).process
            end
          else
            Jekyll.logger.warn 'Pagination:', PAGINATION_DISABLED
          end
        end
      end

      def self.parse_config(configs)
        options = configs['options']
        configuration_filters = []
        configs['filters'].each do |filter|
          configuration_filters << options.merge(filter)
        end
        configuration_filters
      end
    end
  end
end
