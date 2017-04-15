require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters

  class SlimFilter < TiltFilter

    def external_dependencies
      [ 'slim' ]
    end

  end
end
