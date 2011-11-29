module Rake::Pipeline::Web::Filters
  # A filter that wraps JavaScript files in a minispade.register closure
  # for use in minispade.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Wrap each JS file in a minispade.register closure.
  #     filter Rake::Pipeleine::Web::Filters::MinispadeFilter
  #   end
  class MinispadeFilter < Rake::Pipeline::Filter

    # @param [Hash] options
    # @option options [Boolean] :use_strict Whether to add "use strict" to
    #                           each outputted function; defaults to false.
    def initialize(options = {})
      super()
      @use_strict = !!options[:use_strict]
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Wraps each input file in a minispade.register
    # closure.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        code = input.read
        code = '"use strict"; ' + code if @use_strict
        function = "function() { #{code} }"
        ret = "minispade.register('#{input.fullpath.sub(Dir.pwd,'')}',#{function});"
        output.write ret
      end
    end
  end
end
