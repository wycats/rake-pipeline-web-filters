require 'sass'

module Rake::Pipeline::Web::Filters
  # A filter that compiles input files written in SCSS
  # to CSS using the Sass compiler.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.scss"
  #     output "public"
  #
  #     # Compile each SCSS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::SassCompiler
  #   end
  class SassCompiler < Rake::Pipeline::Filter
    # @return [Hash] a hash of options to pass to Sass
    #   when compiling.
    attr_reader :options

    # @param [Hash] options options to pass to the Sass
    #   compiler
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(scss|sass)$/, '.css') }
      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compiles each input file with Sass.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write Sass.compile(input.read, options)
      end
    end
  end
end
