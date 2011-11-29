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
require "rake-pipeline-web-filters/tilt_filter"
require "rake-pipeline-web-filters/sass_compiler"
require "rake-pipeline-web-filters/minispade_filter"
require "rake-pipeline-web-filters/ordering_concat_filter"
