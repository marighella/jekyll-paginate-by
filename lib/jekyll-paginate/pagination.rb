module Jekyll
  module Paginate
    class Pagination < Generator
     attr_reader :site, :per_page, :paginate_by, :template
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
          if site.config['paginate_layout']
            @site = site
            @paginate_by = site.config['paginate_by']
            @per_page = site.config['paginate'].to_i
            @template = site.config['paginate_layout']
            start_pagination
          else
            Jekyll.logger.warn "Pagination:", "Pagination is enabled, but I couldn't find " +
              "an layout page to use as the pagination template, please site.'paginate_layout' in config. Skipping pagination."
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
      def start_pagination
        if site.config["paginate_by"]
          paginate_by = Array(site.config['paginate_by'])
          paginate_by.each do |attr| 
            groups = site.posts.group_by { |post| post.data[attr] }
            generate_grouped_pages(groups)
          end
        else
          #generate_pages(site.posts)
        end
      end

      def generate_grouped_pages(groups)
        groups.each do |group_name, posts|
          paginate_folder = site.config['paginate_folder']
          dir_name = paginate_folder
          if !group_name.nil? && !group_name.empty?
            dir_name = [Slugify.convert(group_name), dir_name].join('/')
          end
          generate_pages(posts, template, dir_name)
        end
      end
      
      def generate_pages( posts, template,  dir = nil)
        pages = Pager.calculate_pages(posts, per_page)
        (1..pages).each do |num_page|
          newpage = Page.new(site, site.source, template, 'index.html')
          newpage.pager =  Pager.new(site, num_page, posts, pages, dir)
          newpage.dir = Pager.paginate_path(site, num_page, dir)
          site.pages << newpage
        end
      end
      # Static: Fetch the URL of the template page. Used to determine the
      #         path to the first pager in the series.
      #
      # site - the Jekyll::Site object
      #
      # Returns the url of the template page
      def self.first_page_url(site)
        if page = Pagination.new.template_page(site)
          page.url
        else
          nil
        end
      end

      # Public: Find the Jekyll::Page which will act as the pager template
      #
      # site - the Jekyll::Site object
      #
      # Returns the Jekyll::Page which will act as the pager template
      def template_page(site)
        site.pages.dup.select do |page|
          Pager.pagination_candidate?(site.config, page)
        end.sort do |one, two|
          two.path.size <=> one.path.size
        end.first
      end

    end
  end
end
