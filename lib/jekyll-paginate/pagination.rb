module Jekyll
  module Paginate
    class Pagination < Generator
     attr_reader :site,:paginate_path, :per_page, :template
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
            @paginate_path = site.config["paginate_path"]
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
        posts = Array.new(site.posts)
        if excludes = site.config['paginate_exclude']
          excludes.each do |exclude|
            exclude.each do |key, value|
              posts =  posts.delete_if {|item|item.data[key] == value}
            end
          end
        end
        if attr_name = site.config["paginate_by_attr"]
          paginate_by_attr(attr_name, posts)
        end
        if tag_names = site.config["paginate_by_tags"]
          paginate_by_tag(tag_names, posts)
        end
        generate_pages(site.posts.reverse, template, "noticias")
      end

      def paginate_by_attr(attr_names, posts)
        dir_name = site.config["paginate_by_attr_path"] || "categories"
        attr_names.each do |attr|
          groups = site.posts.group_by { |post| post.data[attr] }
          generate_grouped_pages(groups, dir_name)
        end
      end

      def paginate_by_tag(attr_name, posts)
        posts = site.posts
        dir_name = site.config["paginate_tag_path"] || "tags"
        groups = {}
        posts.each do |post|
          if data = post.data[attr_name]
            data.each do |tag|
              groups[tag.values.first] ||= []
              groups[tag.values.first] <<  post
            end
          end
        end
        generate_grouped_pages(groups, dir_name) if groups.size > 0 
      end

      def generate_grouped_pages(groups, dir_name)
        groups.each do |group_name, posts|
          if !group_name.nil? && !group_name.empty?
            path = [dir_name, Slugify.convert(group_name)].compact.reject{|s| s.empty?}.join('/')
            generate_pages(posts.reverse, template, path)
          end
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
