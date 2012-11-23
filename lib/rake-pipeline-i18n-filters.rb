require "rake-pipeline"

module Rake
  class Pipeline
    module I18n
      module Filters
      end
    end
  end
end

require "ext/hash"
require "rake-pipeline-i18n-filters/version"
require "rake-pipeline-i18n-filters/filter_with_dependencies"
require "rake-pipeline-i18n-filters/i18n_js_filter"
require "rake-pipeline-i18n-filters/ember_strings_filter"
require "rake-pipeline-i18n-filters/helpers"
