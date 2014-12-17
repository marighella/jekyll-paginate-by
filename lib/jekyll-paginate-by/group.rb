module Jekyll
  module PaginateBy
    class Group < Struct.new(:name, :posts, :permalink)
     def path
       name = self.name || ""
       permalink.sub("$", Slugify.convert(name))
      end
    end
  end
end
