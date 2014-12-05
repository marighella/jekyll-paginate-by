# Jekyll::Paginate

Default pagination generator for Jekyll.

[![Build Status](https://secure.travis-ci.org/jekyll/jekyll-paginate.svg?branch=master)](https://travis-ci.org/jekyll/jekyll-paginate)

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-paginate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-paginate

Once the gem is installed on your system, Jekyll will auto-require it. Just set the following configuration

## Optional settings

 Add to `_config.yml`:

    paginate_by:
        - menu:
            per_page: 20
            limit_pages: 10
            permalink: "editorias/$"
            template: "_templates/list"
            page_link: "page:num"
            exclude:
            - section: "campaign"
            - section: "newspaper"
        - tags:
            is_tag: true
            per_page: 20
            limit_pages: 10
            permalink: "tags/$"
            template: "_templates/list"
            page_link: "page:num"



## Contributing

1. Fork it ( http://github.com/jekyll/jekyll-paginate/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
