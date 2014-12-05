require 'spec_helper'
require 'pry'
require 'yaml'
require_relative "../lib/jekyll-paginate/pagination_generator"
require_relative "../lib/jekyll-paginate/group"


describe(Jekyll::Paginate::PaginationGenerator) do
  let(:config) { pagination_config }
  let(:excluded_posts) { [mock_post({"category"=> "excluded"})] }
  let(:posts) do
    result = list_mock_post(100, {'category'=> 'category_a'})
    result +=  list_mock_post(100,{'category'=>'category_b'})
    result += excluded_posts
    result
  end
 
  describe 'static methods' do
    it '.parse_config' do 
      expect(described_class.parse_config(config).has_key?("attr_name")).to be(true) 
    end
  end
  #
  describe 'instance methods' do
    let(:site){ build_site }
    subject(:instance) { described_class.new(config, site) }


    it "#pages_count" do 
      expect(instance.pages_count(100)).to eq(5)
    end

    it "#filter_posts" do
      expect(instance.filter_posts(posts,[{"category"=> "excluded"}]).size).to be == (posts.size - excluded_posts.size)
    end
    it "#parse_permalink" do 
      expect(instance.parse_permalink("categories/my-animal/$",'cat')).to eq('categories/my-animal/cat')
    end

    it "#group_by_attr" do 
      expect(instance.group_by_attr(posts,'category').first).to be_kind_of(Jekyll::Paginate::Group)
    end

    describe "#create_group_pagination" do
      let(:group) { Jekyll::Paginate::Group.new('group-name', posts) } 
     subject(:result) { instance.create_group_pagination(group) }
     it { expect(result).to be_kind_of(Array)}
     it { expect(result.first.url).to be == "/categories/group-name/index.html" }
     it { expect(result[1].url).to be == "/categories/group-name/page2/index.html" }
     it { expect(result.size).to be == instance.pages_count(posts.size) }
    end
    
    it "#process_groups" do 
      groups = instance.group_by_attr(posts, "category")
      expect(instance.process_groups(groups).size).to be == 11
    end

    describe "#process" do 
      subject(:result) { instance.process(posts) }
      it { expect(result).to be_kind_of(Array)}
      it { expect(result.first.url).to be == "/categories/category-b/index.html" }
      it { expect(result[1].url).to be == "/categories/category-b/page2/index.html" }
      it { expect(result.size).to be == instance.pages_count((posts-excluded_posts).size) }
    end
  end
end

