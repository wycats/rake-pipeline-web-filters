require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compresses CSS input files using
  # the YUI CSS compressor.
  #
  # Requires {https://rubygems.org/gems/yui-compressor yui-compressor}
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Compress each CSS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::YUICssFilter
  #   end
  class YUICssFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to the
    #   YUI compressor when compressing.
    attr_reader :options

    # @param [Hash] options options to pass to the YUI
    #   CSS compressor.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| 
        if input =~ %r{min.css$}
          input
        else
          input.sub /\.css$/, '.min.css'
        end
      }

      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compresses each input file with
    # the YUI CSS compressor.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      compressor = YUI::CssCompressor.new(options)
      inputs.each do |input|
        if input.path !~ /min\.css/
          output.write compressor.compress(input.read)
        else
          output.write input.read
        end
      end
    end

  private

    def external_dependencies
      [ 'yui/compressor' ]
    end
  end
end

