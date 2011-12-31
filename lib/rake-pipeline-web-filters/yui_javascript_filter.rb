require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compresses JavaScript input files using
  # the YUI JavaScript compressor.
  #
  # Requires {https://rubygems.org/gems/yui-compressor yui-compressor}
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Compress each JS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::YUIJavaScriptFilter
  #   end
  class YUIJavaScriptFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to the
    #   YUI compressor when compressing.
    attr_reader :options

    # @param [Hash] options options to pass to the YUI
    #   JavaScript compressor.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.js$/, '.min.js') }
      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compresses each input file with
    # the YUI JavaScript compressor.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      compressor = YUI::JavaScriptCompressor.new(options)
      inputs.each do |input|
        output.write compressor.compress(input.read)
      end
    end

    private

    def external_dependencies
      [ 'yui/compressor' ]
    end
  end
end

