module Rake::Pipeline::Web::Filters
  # A filter that converts handlebars templates to javascript
  # and stores them in a defined variable.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.handlebars"
  #     output "public"
  #
  #     # Compile each handlebars file to JS
  #     handlebars
  #   end
  class HandlebarsFilter < Rake::Pipeline::Filter

    attr_reader :options

    # @param [Hash] options
    #   options to pass to the output generator
    # @option options [Array] :target
    #   the variable to store templates in
    # @option options [Array] :compile_open
    #   the js to wrap template contents in
    # @option options [Array] :compile_close
    #   the js to wrap template contents in
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={},&block)
      # Convert .handlebars file extensions to .js
      block ||= proc { |input| input.sub(/\.handlebars$/, '.js') }
      super(&block)
      @options = {
          :target =>'Ember.TEMPLATES',
          :compile_open => 'Ember.Handlebars.compile(',
          :compile_close => ');'
        }.merge(options)
    end

    def generate_output(inputs, output)

      inputs.each do |input|
        # The name of the template is the filename, sans extension
        name = File.basename(input.path, File.extname(input.path))

        # Read the file and escape it so it's a valid JS string
        source = input.read.to_json

        # Write out a JS file, saved to target, wrapped in compiler
        output.write "\n#{options[:target]}['#{name}']=#{options[:compile_open]}#{source}#{options[:compile_close]}\n"
      end
    end
  end
end