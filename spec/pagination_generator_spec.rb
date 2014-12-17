require 'spec_helper'
require 'yaml'


describe(Jekyll::PaginateBy::PaginationGenerator) do
  let(:config) { pagination_config }
  let(:excluded_posts) { [mock_post({"category"=> "excluded"})] }
  let(:posts_with_category_a) {list_mock_post(100, {'category'=> 'category_a', 'tags'=> [{'tag' => 'tagA'}, {'tag' => 'tabB'}]})}
  let(:posts) do
    result = posts_with_category_a
    result +=  list_mock_post(100,{'category'=>'category_b'})
    result += excluded_posts
    result
  end
 
  describe 'instance methods' do
    let(:site){ build_site }
    subject(:instance) { described_class.new(config["filters"].first, site) }

    it "#pages_count" do 
      expect(instance.pages_count(100)).to eq(5)
    end

    it "#exclude_posts" do
      expect(instance.exclude_posts(posts,[{"category"=> "excluded"}]).size).to be == (posts.size - excluded_posts.size)
    end

    it "#group_by_attr" do 
      expect(instance.group_by_attr(posts,'category').first).to be_kind_of(Jekyll::PaginateBy::Group)
    end

    it "#group_by_tag" do 
      expect(instance.group_by_tag(posts,'tags').first).to be_kind_of(Jekyll::PaginateBy::Group)
    end

    describe "#create_group_pagination" do
      let(:group) { Jekyll::PaginateBy::Group.new('group-name', posts, "categories/$") } 
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

    it "#only" do
      expect(instance.only_posts(posts,[{"category"=> "category_a"}]).size).to be == (posts.size - posts_with_category_a.size- excluded_posts.size)
    end
  end
end

