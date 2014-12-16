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
        posts = exclude_posts(posts, @excludes)
        posts = only_posts(posts, @only) if @only
        if @attr_name == "all"
          groups = process_all(posts)
        else
          groups = process_with_filters(posts)
        end
        process_groups(groups)
      end
     
      def process_with_filters(posts)
        if @is_tag
          groups = group_by_tag(posts, @attr_name)
        else
          if is_collection?
            groups = [Group.new(@attr_name, posts, @permalink)]
          else
            groups = group_by_attr(posts, @attr_name)
          end
        end
      end

      def process_all(posts)
        [Group.new("all", posts, @permalink)]
      end

      def is_collection?
        @permalink.include?("$") == false
      end
    
      def process_groups(groups)
        result = []
        groups.each do |group|
          unless group.name.nil?
            result +=  create_group_pagination(group)
          end
        end
        result
      end

      def group_by_attr(posts, attr)
        posts.group_by { |post| post.data[attr] }.map { |name, posts| Group.new(name, posts, @permalink) }
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
        groups.map { |name, posts| Group.new(name, posts, @permalink) }
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
        path = group.path
        newpage = Page.new(site, site.source, @template, 'index.html')
        newpage.pager =  Pager.new(path, @per_page, num_page, group.posts, total_pages, @page_link)
        newpage.dir = Pager.paginate_path(path, num_page, @page_link)
        newpage
      end

      def exclude_posts(posts, excludes)
        posts = Array.new(posts)
        excludes = Array(excludes)
        excludes.each do |exclude|
          exclude.each do |key, value|
            posts.delete_if {|item| item.data[key] == value}
          end
        end
        posts.reverse
      end

      def only_posts(posts, criterias)
        result = []
        criterias = Array(criterias)
        require 'pry'
        binding.pry
        criterias.each do |criteria|
          criteria.each do |key, value|
            result += posts.select {|item| item.data[key] == value}
          end
        end
        result
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
        if config.fetch(attr_name).is_a? Hash
          result.merge!(config.fetch(attr_name))
        end
        result["attr_name"] = attr_name
        result
      end

    end
  end
end
