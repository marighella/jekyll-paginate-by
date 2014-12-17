module Jekyll
  module PaginateBy
    class Pagination < Generator
      attr_reader :site
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
          if configs =  site.config['paginate_by']
            configs = Pagination.parse_config(configs)
            configs["filters"].each do |config|
              site.pages +=PaginationGenerator.new(config, site).process
            end
          else
            Jekyll.logger.warn "Pagination:", "Pagination is enabled, but I couldn't find " +
              "an layout page to use as the pagination template, please site.'paginate_by' in config. Skipping pagination."
          end
        end
      end

      def self.parse_config(configs)
        options = configs["options"]
        root_keys = Array.new(options.keys)
        configs["filters"].each do |filter|
          filter.keys.each do |filter_key_name|
            root_keys.each do |key|
              unless filter[filter_key_name].has_key? key
                filter[filter_key_name][key] = options[key]
              end
            end
          end
        end
        configs
      end
    end
  end
end
