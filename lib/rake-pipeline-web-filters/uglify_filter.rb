require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that uses the Uglify JS compressor to compress
  # JavaScript input files.
  #
  # Requires {http://rubygems.org/gems/uglifier uglifier}.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Compile each JS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::UglifyFilter
  #   end
  class UglifyFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to Uglify
    #   when compiling.
    attr_reader :options

    # @param [Hash] options options to pass to Uglify
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| 
        if input =~ %r{min.js$}
          input
        else
          input.sub(/\.js$/, '.min.js')
        end
      }

      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compiles each input file with Uglify.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        if input.path =~ %r{min.js$}
          output.write input.read
        else
          output.write Uglifier.compile(input.read, options)
        end
      end
    end

    private

    def external_dependencies
      [ 'uglifier' ]
    end
  end
end
