module Jekyll
  module PaginateBy
    class Pager
      attr_reader :page, :per_page, :posts, :total_posts, :total_pages,
        :previous_page, :previous_page_path, :next_page, :next_page_path, :first_page_path

      # Calculate the number of pages.
      #
      # all_posts - The Array of all Posts.
      # per_page  - The Integer of entries per page.
      #
      # Returns the Integer number of pages.
      def self.calculate_pages(all_posts, per_page)
        (all_posts.size.to_f / per_page.to_i).ceil
      end

      # Determine if pagination is enabled the site.
      #
      # site - the Jekyll::Site object
      #
      # Returns true if pagination is enabled, false otherwise.
      def self.pagination_enabled?(site)
        !site.config['paginate_by'].nil? &&
         site.pages.size > 0
      end
      # Static: Return the pagination path of the page
      #
      # site     - the Jekyll::Site object
      # num_page - the pagination page number
      #
      # Returns the pagination path as a string
      def self.paginate_path(path, num_page, page_link = nil)
        return nil if num_page.nil?
        if num_page <= 1
          return ensure_leading_slash(path)
        end
        format = [path, page_link].compact.join("/")
        format = format.sub(':num', num_page.to_s)
        ensure_leading_slash(format)
      end

      # Static: Return a String version of the input which has a leading slash.
      #         If the input already has a forward slash in position zero, it will be
      #         returned unchanged.
      #
      # path - a String path
      #
      # Returns the path with a leading slash
      def self.ensure_leading_slash(path)
        path[0..0] == "/" ? path : "/#{path}"
      end

      # Static: Return a String version of the input without a leading slash.
      #
      # path - a String path
      #
      # Returns the input without the leading slash
      def self.remove_leading_slash(path)
        ensure_leading_slash(path)[1..-1]
      end

      # Initialize a new Pager.
      #
      # path      - The Path of pagination
      # per_page  - The Posts per page configuration
      # page      - The Integer page number.
      # all_posts - The Array of all the site's Posts.
      # num_pages - The Integer number of pages or nil if you'd like the number
      #             of pages calculated.
      def initialize(path, per_page, page, all_posts, num_pages, page_link)
        @page = page
        @per_page = per_page
        @total_pages = num_pages 
        if @page > @total_pages
          raise RuntimeError, "page number can't be greater than total pages: #{@page} > #{@total_pages}"
        end

        init = (@page - 1) * @per_page
        offset = (init + @per_page - 1) >= all_posts.size ? all_posts.size : (init + @per_page - 1)
        @first_page_path = Pager.paginate_path(path, 1, page_link)
        @total_posts = all_posts.size
        @posts = all_posts[init..offset]
        @previous_page = @page != 1 ? @page - 1 : nil
        @previous_page_path = Pager.paginate_path(path, @previous_page, page_link)
        @next_page = @page != @total_pages ? @page + 1 : nil
        @next_page_path = Pager.paginate_path(path, @next_page, page_link)
      end

      # Convert this Pager's data to a Hash suitable for use by Liquid.
      #
      # Returns the Hash representation of this Pager.
      def to_liquid
        {
          'page' => page,
          'per_page' => per_page,
          'posts' => posts,
          'total_posts' => total_posts,
          'total_pages' => total_pages,
          'previous_page' => previous_page,
          'previous_page_path' => previous_page_path,
          'next_page' => next_page,
          'next_page_path' => next_page_path,
          'first_page_path' => first_page_path
        }
      end

    end
  end
end
