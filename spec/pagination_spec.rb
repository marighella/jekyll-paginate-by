require 'spec_helper'
require 'yaml'
require_relative "../lib/jekyll-paginate-by/pagination"


describe(Jekyll::PaginateBy::Pagination) do
  let(:config) { {"defaults" => {"permanlink"=> "teste", "name"=> "my name" } , "filters"=> ["category"=>{"name"=> "ola"}]} }
  it { expect(described_class.parse_config(config)).to eq( {"defaults" => { "permanlink"=> "teste", "name"=> "my name" } , "filters" => [{"category"=>{"name"=>"ola", "permanlink"=>"teste"}}]}) } 
end
