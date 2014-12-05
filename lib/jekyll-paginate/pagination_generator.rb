require_relative 'group'
module Jekyll
  module Paginate
    class PaginationGenerator

      def initialize(config, site)
        @site = site
        @raw_posts = copy_posts(@site.posts)
        @config = PaginationGenerator.parse_config(config)
        @excludes = @config['exclude'] || []
        @pages_limit = @config['pages_limit'] || nil
        @per_page = @config['per_page'] || 10
        @template = @config['template']
        @attr_name = @config['attr_name']
        @is_tag = @config["is_tag"]
        @page_link = @config['page_link']
        @permalink = @config['permalink'] ||  [Slugify.convert(attr_name), "$"].join('/')
      end

      def copy_posts(posts)
        Array.new(posts)
      end

      def process(posts = nil)
        posts = posts ||  @raw_posts 
        posts = filter_posts(posts, @excludes) 
        if @is_tag
          groups = group_by_tag(posts, @attr_name)
        else
          groups = group_by_attr(posts, @attr_name)
        end
        process_groups(groups)
      end

      def process_groups(groups)
        result = []
        groups.each do |group|
          if !group.name.nil? && !group.name.empty?
            result +=  create_group_pagination(group)
          end
        end
        result
      end

      def group_by_attr(posts, attr)
        posts.group_by { |post| post.data[attr] }.map { |name, posts| Group.new(name, posts) }
      end

      def group_by_tag(posts, attr)
        groups = {}
        posts.each do |post|
          if data = post.data[attr]
            data.each do |tag|
              groups[tag.values.first] ||= []
              groups[tag.values.first] <<  post
            end
          end
        end
        groups
      end
      def create_group_pagination(group)
        total = pages_count(group.posts.size)
        result = []
        (1..total).each do |num_page|
          result << create_page(@site, group, num_page, total)
        end
        result
      end

      def create_page(site, group, num_page, total_pages)
          path = parse_permalink(@permalink,group.name)
          newpage = Page.new(site, site.source, @template, 'index.html')
          newpage.pager =  Pager.new(path,@per_page, num_page, group.posts, total_pages, path)
          newpage.dir = Pager.paginate_path(@page_link, num_page, path)
          newpage
      end

      def filter_posts(posts, excludes)
        posts = Array.new(posts)
        excludes.each do |exclude|
          exclude.each do |key, value|
            posts.delete_if {|item| item.data[key] == value}
          end
        end
        posts.reverse
      end

      def parse_permalink(permalink, attr_name)
        permalink.sub("$", Slugify.convert(attr_name))
      end

      def pages_count(posts_count)
        result = (posts_count.to_f / @per_page.to_i).ceil
        if @pages_limit
          result = result <= @pages_limit ? result : @pages_limit
        end
        result
      end

      def self.parse_config(config)
        result = {}
        attr_name = config.keys.first
        result.merge!(config.fetch(attr_name))
        result["attr_name"] = attr_name
        result
      end

    end
  end
end
