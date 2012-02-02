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
  module Helpers
    # Add a new {MinispadeFilter} to the pipeline.
    # @see MinispadeFilter#initialize
    def minispade(*args, &block)
      filter(Rake::Pipeline::Web::Filters::MinispadeFilter, *args, &block)
    end

    # Add a new {SassFilter} to the pipeline.
    # @see SassFilter#initialize
    def sass(*args, &block)
      filter(Rake::Pipeline::Web::Filters::SassFilter, *args, &block)
    end
    alias_method :scss, :sass

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
    def coffee_script(&block)
      filter(Rake::Pipeline::Web::Filters::CoffeeScriptFilter, &block)
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
  end
end

Rake::Pipeline::DSL.send(:include, Rake::Pipeline::Web::Filters::Helpers)
