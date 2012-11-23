module Rake::Pipeline::I18n::Filters
  # Extends the Rake::Pipeline DSL to include shortcuts
  # for adding filters to the pipeline.
  module PipelineHelpers
    # Add a new {I18nJsFilter} to the pipeline
    # @see I18nJsFilter#initialize
    def i18n_js(*args, &block)
      filter(Rake::Pipeline::I18n::Filters::I18nJsFilter, *args, &block)
    end
    # Add a new {EmberStringsFilter} to the pipeline
    # @see EmberStringsFilter#initialize
    def ember_strings(*args, &block)
      filter(Rake::Pipeline::I18n::Filters::EmberStringsFilter, *args, &block)
    end
  end
end

require "rake-pipeline/dsl"
Rake::Pipeline::DSL::PipelineDSL.send(:include, Rake::Pipeline::I18n::Filters::PipelineHelpers)
