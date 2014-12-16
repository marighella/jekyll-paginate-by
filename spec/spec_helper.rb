require 'jekyll'
require File.expand_path("../lib/jekyll-paginate", File.dirname(__FILE__))

RSpec.configure do |config|
  config.order = 'random'

  def test_dir(*subdirs)
    File.join(File.dirname(__FILE__), *subdirs)
  end

  def dest_dir(*subdirs)
    test_dir('dest', *subdirs)
  end

  def source_dir(*subdirs)
    test_dir('source', *subdirs)
  end

  def build_configs(overrides, base_hash = Jekyll::Configuration::DEFAULTS)
    Jekyll::Utils.deep_merge_hashes(base_hash, overrides)
  end

  def pagination_config(overrides = {})
    YAML.load_file(test_dir('_config.yml')).merge(overrides)["paginate_by"]
  end

  def site_configuration(overrides = {})
    config =  build_configs({
      "source"      => source_dir,
      "destination" => dest_dir
    }, build_configs(overrides))
    config
  end

  def list_mock_post (amount, overrides = {})
    posts = []
    (amount).times do 
      posts << mock_post(overrides)
    end
    posts
  end

  def mock_post(overrides = {})
    default = { "title"=> 'a post title',"category"=> 'category' }
    post_data = default.merge(overrides)
    post = instance_double("Post")
    allow(post).to receive(:data) { post_data }
    post
  end

  def build_site(config = {})
    site = Jekyll::Site.new(site_configuration(
      build_configs(YAML.load_file(test_dir('_config.yml'))).merge(config)
    ))
    #site.process
    site
  end
end
