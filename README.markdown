# Rake::Pipeline::Web::Filters [![Build Status](https://secure.travis-ci.org/wycats/rake-pipeline-web-filters.png?branch=master)](http://travis-ci.org/wycats/rake-pipeline-web-filters)

This project contains a set of rake-pipeline filters for building web
apps.

It includes these filters:

* Cache Buster - Write a fingerprint into each file name
* Coffescript - Convert Coffeescript to Javascript
* ES6 Module Transpiler - Transpile ES6 to ES5 Javascript ([Available Options](https://github.com/square/es6-module-transpiler))
* GZip - Create gzip'd version of your files
* Handlebars - Process handlebars templates
* IIFE - Wrap source files in Immediately Invoked Function Expressions
* Jade - Process Jade templates
* LESS - Convert LESS to CSS
* Markdown - Convert Markdown to HTML
* Minispade - Wrap JS files in Minispade modules
* Neuter - Require files in a file and generate one single combined file
* SASS - Convert SASS to CSS
* Stylus - Convert Stylus to CSS
* Tilt - Use Tilt to process
* Uglify - Minify JS
* YUI CSS - Minify CSS
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
