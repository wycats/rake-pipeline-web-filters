require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # Evalute each file as an ERB template
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js.erb"
  #     output "public"
  #
  #     # Compile each JS file under the app/assets
  #     # directory as an ERB template
  #     filter Rake::Pipeline::Web::Filters::ErbFilter
  #   end
  class ErbFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @param [Binding] binding to evaluate the template in
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(binding = binding, &block)
      @binding = binding
      block ||= proc { |input| input.gsub(/\.erb$/, '') }
      super(&block)
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Parses each file as an ERB template
    # and evaluates it against the {binding}
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write ERB.new(input.read).result(@binding)
      end
    end

    private

      def external_dependencies
        [ 'erb' ]
      end
  end
end
