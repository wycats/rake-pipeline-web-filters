module Rake::Pipeline::Web::Filters
  # A filter that generates Tilt templates where the templates may yield
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     output "public"
  #
  #     # Below, the layout yields to the index; i.e., there will be a
  #     # call to yield inside layout.slim. The resulting file generated
  #     # will be index.html
  #     input "assets" do
  #       match "templates/{layout,index}.slim" do
  #         tilt_yielding :yields_to => ["layout","index"], :output_name => "index.html"
  #       end
  #     end
  #
  #     # If you need to match the same layout again, it needs to be in
  #     # its own input block
  #     input "assets" do
  #       match "templates/{layout,about}.slim" do
  #         tilt_yielding :yields_to => ["layout","about"], :output_name => "about.html"
  #       end
  #     end
  #   end
  class TiltYieldingFilter < Rake::Pipeline::Filter

    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @param [Hash] options is used by the filter and the generator
    # @option options [String] :output_name is the file name that will be
    #   used for the resulting file from generation
    # @option options [Array] :yields_to is the array in which the
    #   templates will be ordered upon generation, for instance, given
    #   [a,b,c], a yields_to b and b yields_to c, which means that the
    #   result of c is nested in b, and that result is nested in a.
    # @option options [Object] :scope is the scope that will be passed
    #   on each render of the templates
    # @option options [Hash] :locals is the Hash of local variables that
    #   will be passed on each render of the templates
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}, which by default will group all the
    #   inputs to the @output_name. Note that if this is proc is
    #   overridden then it is important that inputs are grouped to the
    #   result of the proc
    def initialize options = {}, &block
      @output_name = options.delete(:output_name) || DEFAULT_OUTPUT_NAME
      @yields_to = options.delete(:yields_to) || []
      @scope = options.delete(:scope) || Object.new
      @locals = options.delete(:locals) || {}
      @options = options
      super(&block || ->_ {@output_name})
    end

    def generate_output inputs, output
      output.write invoke_tilt(order_inputs inputs)
    end

    private 
    DEFAULT_OUTPUT_NAME = "a.out"
    def external_dependencies; ["tilt"]; end

    # Determines if the value matches the given input, where the value
    # will be an item in the @yields_to array, and the input will be an
    # item in the array of inputs. The method returns true when the file
    # name of the input without an extension equals the value.
    def matches_input? value, input
      File.basename(input.path,File.extname(input.path)) == value
    end

    # Orders the inputs according to the @yields_to array. This method
    # takes a list of inputs and returns the same list of inputs,
    # potentially in a different order. The reverse occurs at the end
    # because Tile must process the inner-most template first and pass
    # it up the yields_to chain. So the user specifies the @yields_to in
    # terms of a yields to b, but we process b and pass it in when a is
    # processed.
    def order_inputs inputs
      case @yields_to
        when [] then inputs
        else
          @yields_to.
            map {|a| inputs.index {|b| matches_input? a,b}}.
            map {|a| inputs[a]}
      end.reverse
    end

    # Generates the result of invoking tilt on each of the inputs where
    # each sequential input is nesteded within the next input. So we
    # expect that the ordering of the inputs is bottom to top.
    def invoke_tilt inputs
      inputs.reduce("") do |b,a|
        # Filename, line number, options
        Tilt[a.path].new(nil,1,@options) {|_| a.read}.render(@scope,@locals) {b}
      end
    end
  end
end
