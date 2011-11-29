require 'tilt'

module Rake::Pipeline::Web::Filters
  # A filter that accepts a series of inputs and translates
  # them using the Tilt template interface, which will attempt
  # to guess which template language to use based on the input
  # file extension.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.scss"
  #     output "public"
  #
  #     # Compile each SCSS file using Tilt, replacing the
  #     # scss extension with css.
  #     filter(Rake::Pipeline::Web::Filters::TiltFilter) do |input|
  #       input.sub(/\.scss$/, 'css')
  #     end
  #   end
  class TiltFilter < Rake::Pipeline::Filter
    # @return [Hash] a hash of options to pass to Tilt
    #   when rendering.
    attr_reader :options

    # @param [Hash] options options to pass to the Tilt
    #   template class constructor.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Attempts to compile each input file
    # with Tilt, passing the file through unchanged if Tilt
    # can't find a template class for the file.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        out = if (template_class = Tilt[input.path])
          template_class.new(nil, 1, options) { |t| input.read }.render
        else
          input.read
        end

        output.write out
      end
    end
  end
end
