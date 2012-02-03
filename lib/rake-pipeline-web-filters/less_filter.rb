require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that accepts a series of inputs and translates
  # them using the Tilt template interface, which will attempt
  # to guess which template language to use based on the input
  # file extension.
  #
  # Requires {https://rubygems.org/gems/less-js less-js}
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.less"
  #     output "public"
  #
  #     # Compile each less file with Less.js
  #     filter Rake::Pipeline::Web::Filters::LessFilter
  #   end
  class LessFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to Less
    #   when compiling.
    attr_reader :options

    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, context = nil, &block)
      block ||= proc { |input| input.sub(/\.less$/, '.css') }
      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Attempts to compile each input file
    # with LessJs.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      parser = Less::Parser.new options
      inputs.each do |input|
        output.write parser.parse(input.read).to_css
      end
    end

    def external_dependencies
      [ 'less' ]
    end
  end
end
