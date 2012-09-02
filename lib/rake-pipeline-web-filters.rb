require "rake-pipeline"

module Rake
  class Pipeline
    module Web
      module Filters
      end
    end
  end
end

require "rake-pipeline-web-filters/version"
require "rake-pipeline-web-filters/cache_buster_filter"
require "rake-pipeline-web-filters/filter_with_dependencies"
require "rake-pipeline-web-filters/markdown_filter"
require "rake-pipeline-web-filters/minispade_filter"
require "rake-pipeline-web-filters/neuter_filter"
require "rake-pipeline-web-filters/sass_filter"
require "rake-pipeline-web-filters/stylus_filter"
require "rake-pipeline-web-filters/tilt_filter"
require "rake-pipeline-web-filters/coffee_script_filter"
require "rake-pipeline-web-filters/yui_javascript_filter"
require "rake-pipeline-web-filters/yui_css_filter"
require "rake-pipeline-web-filters/gzip_filter"
require "rake-pipeline-web-filters/uglify_filter"
require "rake-pipeline-web-filters/chained_filter"
require "rake-pipeline-web-filters/less_filter"
require "rake-pipeline-web-filters/handlebars_filter"
require "rake-pipeline-web-filters/iife_filter"
require "rake-pipeline-web-filters/helpers"
