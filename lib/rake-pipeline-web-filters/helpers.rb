module Rake::Pipeline::Web::Filters
  # Extends the Rake::Pipeline DSL to include shortcuts
  # for adding filters to the pipeline.
  #
  # Instead of:
  #   !!!ruby
  #   match("*.scss") do
  #     filter Rake::Pipeline::Web::Filters::SassCompiler, :syntax => :sass
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

    # Add a new {SassCompiler} to the pipeline.
    # @see SassCompiler#initialize
    def sass(*args, &block)
      filter(Rake::Pipeline::Web::Filters::SassCompiler, *args, &block)
    end
    alias_method :scss, :sass

    # Add a new {TiltFilter} to the pipeline.
    # @see TiltFilter#initialize
    def tilt(*args, &block)
      filter(Rake::Pipeline::Web::Filters::TiltFilter, *args, &block)
    end

    # Add a new {MarkdownCompiler} to the pipeline.
    # @see MarkdownCompiler#initialize
    def markdown(*args, &block)
      filter(Rake::Pipeline::Web::Filters::MarkdownCompiler, *args, &block)
    end

    # Add a new {CacheBuster} to the pipeline.
    # @see CacheBuster#initialize
    def cache_buster(&block)
      filter(Rake::Pipeline::Web::Filters::CacheBuster, &block)
    end

    # Add a new {CoffeeScriptCompiler} to the pipeline.
    # @see CoffeeScriptCompiler#initialize
    def coffee_script(&block)
      filter(Rake::Pipeline::Web::Filters::CoffeeScriptCompiler, &block)
    end

    # Add a new {YUIJavaScriptCompressor} to the pipeline.
    # @see YUIJavaScriptCompressor#initialize
    def yui_javascript(*args, &block)
      filter(Rake::Pipeline::Web::Filters::YUIJavaScriptCompressor, *args, &block)
    end

    # Add a new {YUICssCompressor} to the pipeline.
    # @see YUICssCompressor#initialize
    def yui_css(*args, &block)
      filter(Rake::Pipeline::Web::Filters::YUICssCompressor, *args, &block)
    end

    # Add a new {UglifyFilter} to the pipeline.
    # @see UglifyFilter#initialize
    def uglify(*args, &block)
      filter(Rake::Pipeline::Web::Filters::UglifyFilter, *args, &block)
    end
  end
end

Rake::Pipeline::DSL.send(:include, Rake::Pipeline::Web::Filters::Helpers)
