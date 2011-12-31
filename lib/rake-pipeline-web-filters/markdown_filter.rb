module Rake::Pipeline::Web::Filters
  # A filter that compiles input files written in Markdown
  # to Markdown using the Redcarpet compiler.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.md"
  #     output "public"
  #
  #     # Compile each .md file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::MarkdownFilter
  #   end
  #
  class MarkdownFilter < Rake::Pipeline::Filter

    # @param [Hash] options options to pass to the markdown
    #   compiler
    # @see http://rubydoc.info/gems/redcarpet/2.0.0/frames for more information
    #   about options
    # @option options [#call] :compiler If you wish to use a different
    #   Markdown compiler, you can do so by passing anything that responds
    #   to `:call`, which will be passed the Markdown text and any
    #   options (other than `:compiler`).
    # @option options [Redcarpet::Render::Base] :renderer a
    #   Redcarpet renderer. Used only if using the default compiler.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(md|mdown|mkdown|markdown)$/, '.html') }
      super(&block)
      @compiler = options.delete(:compiler)
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
        output.write compile(input.read)
      end
    end

    private

    def compile(markdown)
      if @compiler
        @compiler.call(markdown, @options)
      else
        default_compiler.render(markdown)
      end
    end

    def default_compiler
      @default_renderer ||= begin
                            require 'redcarpet'
                            renderer = @options.delete(:renderer) || Redcarpet::Render::HTML.new
                            Redcarpet::Markdown.new(renderer, @options)
                          end
    end

  end
end
