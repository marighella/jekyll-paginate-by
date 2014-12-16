require 'spec_helper'
require 'pry'
require 'yaml'
require_relative "../lib/jekyll-paginate/pagination"


describe(Jekyll::Paginate::Pagination) do
  let(:config) { {"defaults" => {"permanlink"=> "teste", "name"=> "my name" } , "filters"=> ["category"=>{"name"=> "ola"}]} }
  it { expect(described_class.parse_config(config)).to eq( {"defaults" => { "permanlink"=> "teste", "name"=> "my name" } , "filters" => [{"category"=>{"name"=>"ola", "permanlink"=>"teste"}}]}) } 
end
