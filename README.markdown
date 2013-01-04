# Rake::Pipeline::Web::Filters [![Build Status](https://secure.travis-ci.org/wycats/rake-pipeline-web-filters.png?branch=master)](http://travis-ci.org/wycats/rake-pipeline-web-filters)

This project contains a set of rake-pipeline filters for building web
apps. 

It includes these filters:

* Cache Buster - Write a fingerprint into each file name
* Coffescript - Convert Javascript to Coffeescript
* GZip - Create gzip'd version of your files
* Handlebars - Parse handlebars templates
* IIFE - Wrap source files in immediately invoked functional expressions
* Jade - Parse Jade templates
* LESS - Convert LESS to CSS
* Markdown - Convert Markdown to HTML
* Minispade - Wrap JS files in Minispade modules
* Neuter - Require files in a file and generate one single combined file
* SASS - Convert SASS to CSS
* Stylus - Styluss to CSS
* Tilt - Pase Title templates
* Uglify - Minify JS
* YUI CSS - Minifiy CSS
* YUI Javascript - Minify JS

Here's a quick example of a realistic project's Assetfile:

```ruby
# Assetfile
require 'rake-pipeline-web-filters'

output "site"

input "javascripts" do
  match "**/*.coffee" do
    coffee_script
  end

  match "**/*.js" do
    minispade
    concat "application.js"
    uglify
  end
end

input "stylesheets" do
  match "**/*.sass" do
    sass
  end

  match "**/*.css" do
    concat "application.css"
    yui_css
  end
end
```

API documentation is hosted at
<a href="http://rubydoc.info/github/wycats/rake-pipeline-web-filters/master/file/README.yard">rubydoc.info</a>
