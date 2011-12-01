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
    # If the first argument is an Array, add a new {OrderingConcatFilter}
    # to the pipeline. Otherwise add a new {Rake::Pipeline::ConcatFilter}.
    # @see OrderingConcatFilter#initialize
    # @see Rake::Pipeline::ConcatFilter#initialize
    def concat(*args, &block)
      if args.first.kind_of?(Array)
        filter(Rake::Pipeline::Web::Filters::OrderingConcatFilter, *args, &block)
      else
        filter(Rake::Pipeline::ConcatFilter, *args, &block)
      end
    end

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
  end
end

Rake::Pipeline::DSL.send(:include, Rake::Pipeline::Web::Filters::Helpers)
