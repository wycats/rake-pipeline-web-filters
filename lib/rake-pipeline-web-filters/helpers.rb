module Rake::Pipeline::Web::Filters
  # Extends the Rake::Pipeline DSL to include shortcuts
  # for adding filters to the pipeline.
  #
  # Instead of:
  #   !!!ruby
  #   match("*.scss") do
  #     filter Rake::Pipeline::Web::Filters::SassFilter, :syntax => :sass
  #   end
  #
  # You can do:
  #   !!!ruby
  #   match("*.scss") do
  #     sass :syntax => :sass
  #   end
  module PipelineHelpers
    # Add a new {MinispadeFilter} to the pipeline.
    # @see MinispadeFilter#initialize
    def minispade(*args, &block)
      filter(Rake::Pipeline::Web::Filters::MinispadeFilter, *args, &block)
    end

    # Add a new {NeuterFilter} to the pipeline.
    # @see NeuterFilter#initialize
    def neuter(*args, &block)
      filter(Rake::Pipeline::Web::Filters::NeuterFilter, *args, &block)
    end

    # Add a new {SassFilter} to the pipeline.
    # @see SassFilter#initialize
    def sass(*args, &block)
      filter(Rake::Pipeline::Web::Filters::SassFilter, *args, &block)
    end
    alias_method :scss, :sass

    # Add a new {StylusFilter} to the pipeline.
    # @see StylusFilter#initialize
    def stylus(*args, &block)
      filter(Rake::Pipeline::Web::Filters::StylusFilter, *args, &block)
    end

    # Add a new {TiltFilter} to the pipeline.
    # @see TiltFilter#initialize
    def tilt(*args, &block)
      filter(Rake::Pipeline::Web::Filters::TiltFilter, *args, &block)
    end

    # Add a new {MarkdownFilter} to the pipeline.
    # @see MarkdownFilter#initialize
    def markdown(*args, &block)
      filter(Rake::Pipeline::Web::Filters::MarkdownFilter, *args, &block)
    end

    # Add a new {CacheBusterFilter} to the pipeline.
    # @see CacheBusterFilter#initialize
    def cache_buster(&block)
      filter(Rake::Pipeline::Web::Filters::CacheBusterFilter, &block)
    end

    # Add a new {CoffeeScriptFilter} to the pipeline.
    # @see CoffeeScriptFilter#initialize
    def coffee_script(*args, &block)
      filter(Rake::Pipeline::Web::Filters::CoffeeScriptFilter, *args, &block)
    end

    # Add a new {YUIJavaScriptFilter} to the pipeline.
    # @see YUIJavaScriptFilter#initialize
    def yui_javascript(*args, &block)
      filter(Rake::Pipeline::Web::Filters::YUIJavaScriptFilter, *args, &block)
    end

    # Add a new {YUICssFilter} to the pipeline.
    # @see YUICssFilter#initialize
    def yui_css(*args, &block)
      filter(Rake::Pipeline::Web::Filters::YUICssFilter, *args, &block)
    end

    # Add a new {GzipFilter} to the pipeline.
    # @see GzipFilter#initialize
    def gzip(&block)
      filter(Rake::Pipeline::Web::Filters::GzipFilter, &block)
    end

    # Add a new {UglifyFilter} to the pipeline.
    # @see UglifyFilter#initialize
    def uglify(*args, &block)
      filter(Rake::Pipeline::Web::Filters::UglifyFilter, *args, &block)
    end

    # Add a new {LessFilter} to the pipeline.
    # @see LessFilter#initialize
    def less(*args, &block)
      filter(Rake::Pipeline::Web::Filters::LessFilter, *args, &block)
    end

    # Add a new {HandlebarsFilter} to the pipeline.
    # @see HandlebarsFilter#initialize
    def handlebars(*args, &block)
      filter(Rake::Pipeline::Web::Filters::HandlebarsFilter, *args, &block)
    end
    #
    # Add a new {IifeFilter} to the pipeline.
    # @see IifeFilter#initialize
    def iife(*args, &block)
      filter(Rake::Pipeline::Web::Filters::IifeFilter, *args, &block)
    end
  end

  module ProjectHelpers
    # Register a filter class for a particular file extension
    # and add a ChainedFilter as a before filter.
    #
    # If this is the first use of +register+, it will set up
    # the before filter. Subsequent uses will just update the
    # types hash.
    #
    # @see ChainedFilter
    def register(extension, klass)
      if @types_hash
        @types_hash[extension] = klass
      else
        @types_hash = { extension => klass }
        before_filter ChainedFilter, { :types => @types_hash }
      end
    end
  end
end

require "rake-pipeline/dsl"

Rake::Pipeline::DSL::PipelineDSL.send(:include, Rake::Pipeline::Web::Filters::PipelineHelpers)
Rake::Pipeline::DSL::ProjectDSL.send(:include, Rake::Pipeline::Web::Filters::ProjectHelpers)
