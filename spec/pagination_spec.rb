require 'spec_helper'
require 'yaml'
require_relative '../lib/jekyll-paginate-by/pagination'


describe(Jekyll::PaginateBy::Pagination) do
  let(:config) do
    {
      'options' =>
      {
       'permanlink' =>'teste',
       'name'=> 'my name'
      },
      'filters' => [
        'category' =>
        {
          'name' => 'ola'
        }
      ]
    }
  end

  it do
    result = [{'permanlink'=> 'teste', 'name'=>'ola', 'category_name' => 'category'}]
    expect(described_class.parse_config(config)).to eq(result)
  end
end
