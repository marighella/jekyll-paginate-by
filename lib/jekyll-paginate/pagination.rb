module Jekyll
  module Paginate
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
            @site = site
            configs.each do |raw_config|
              attr_name = raw_config.keys.first
              config = raw_config[attr_name]
              config['name'] = attr_name
              start_pagination(config)
            end
          else
            Jekyll.logger.warn "Pagination:", "Pagination is enabled, but I couldn't find " +
           "an layout page to use as the pagination template, please site.'paginate_by' in config. Skipping pagination."
          end
        end

      end

      # Paginates the blog's posts. Renders the index.html file into paginated
      # directories, e.g.: page2/index.html, page3/index.html, etc and adds more
      # site-wide data.
      #
      # site - The Site.
      # page - The index.html Page that requires pagination.
      #
      # {"paginator" => { "page" => <Number>,
      #                   "per_page" => <Number>,
      #                   "posts" => [<Post>],
      #                   "total_posts" => <Number>,
      #                   "total_pages" => <Number>,
      #                   "previous_page" => <Number>,
      #                   "next_page" => <Number> }}
      def start_pagination(config)
        posts = Array.new(site.posts)
        posts = exclude_posts(config, posts) if config['exclude']

        if config['is_tag']
          paginate_by_tag(config, posts)
        else
          paginate_by_attr(config, posts)
        end
       # generate_pages(site.posts.reverse, template, "noticias")
      end

      def exclude_posts(config, posts)
        excludes = config['exclude']
        excludes.each do |exclude|
          exclude.each do |key, value|
            posts.delete_if {|item| item.data[key]  == value}
          end
        end
        posts
      end

      def parse_permalink(config, attr_name)
        link = config['permalink'] || Slugify.convert(config['name'])+ "/$"
        link.sub("$", Slugify.convert(attr_name))
      end
      def paginate_by_attr(config, posts)
        groups = site.posts.group_by { |post| post.data[config['name']] }
        generate_grouped_pages(config, groups)
      end

      def paginate_by_tag(config, posts)
        attr_name = config['name']
        posts = site.posts
        groups = {}
        posts.each do |post|
          if data = post.data[attr_name]
            data.each do |tag|
              groups[tag.values.first] ||= []
              groups[tag.values.first] <<  post
            end
          end
        end
        generate_grouped_pages(config, groups) if groups.size > 0 
      end

      def calculate_pages(config, posts)
        total_pages = Pager.calculate_pages(posts, config['per_page'].to_i)
        if limit_pages = config['limit_pages']
          total_pages = total_pages <= limit_pages ? total_pages : limit_pages
        end
        total_pages
      end

      def generate_grouped_pages(config, groups)
        groups.each do |group_name, posts|
          if !group_name.nil? && !group_name.empty?
            generate_pages(config, posts.reverse, group_name)
          end
        end
      end


      def generate_pages(config, posts, group_name)
        total_pages = calculate_pages(config, posts)
        path = parse_permalink(config, group_name)
        template = config['template']
        (1..total_pages).each do |num_page|
          newpage = Page.new(site, site.source, template, 'index.html')
          newpage.pager =  Pager.new(site, num_page, posts, total_pages, path)
          newpage.dir = Pager.paginate_path(site, num_page, path)
          site.pages << newpage
        end
      end
    end
  end
end
