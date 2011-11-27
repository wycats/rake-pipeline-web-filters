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
require "rake-pipeline-web-filters/tilt"
require "rake-pipeline-web-filters/sass_compiler"
