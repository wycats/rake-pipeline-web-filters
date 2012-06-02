require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # Public: The RoyFilter compiles scripts written in Roy to JavaScript.
  #
  # This filter depends on the roy-lang gem.
  #
  # Examples
  #
  #   The following is an example Assetfile usage.
  #
  #   output "public"
  #
  #   input "assets" do
  #     match "*.roy" do
  #       roy
  #     end
  #   end
  class RoyFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # Public: Returns the hash of options used when compiling.
    attr_reader :options

    # Public: Initializes a RoyFilter.
    #
    # options - The Hash of options to use when compiling (default: {}):
    #           See the roy-lang gem for available options.
    # block   - A block to map input names to ouput names (defaults to
    #           mapping .roy files to .js).
    def initialize(options = {}, &block)
      super &(block || ->input {input.sub(/\.roy\z/, ".js")})
      @options = options
    end

    protected
    # Internal: Generates a JavaScript output file containing each
    # compiled input.
    #
    # inputs - Array of FileWrappers of Roy files.
    # output - A FileWrapper of a JavaScript file.
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write Roy.compile(input.read, @options)
      end
    end

    private
    # Internal: Defines the external dependencies of this filter.
    #
    # Returns an Array of the dependencies.
    def external_dependencies
      ["roy-lang"]
    end
  end
end
