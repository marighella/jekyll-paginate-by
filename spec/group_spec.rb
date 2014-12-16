require 'spec_helper'
require 'pry'
require 'yaml'
require_relative "../lib/jekyll-paginate/pagination_generator"
require_relative "../lib/jekyll-paginate/group"


describe(Jekyll::Paginate::Group) do
  describe "#parse_permalink" do
    subject(:instance) { described_class.new("cat", [], "categories/$") }
    it "with $" do
      expect(instance.path).to eq('categories/cat')
    end
    it "without $" do
      instance.permalink = "categories/"
      expect(instance.path).to eq('categories/')
    end
  end
end
