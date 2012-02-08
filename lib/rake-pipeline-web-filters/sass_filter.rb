require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compiles input files written in SCSS
  # to CSS using the Sass compiler and the Compass CSS
  # framework.
  #
  # Requires {http://rubygems.org/gems/sass sass} and
  # {http://rubygems.org/gems/compass compass}
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.scss"
  #     output "public"
  #
  #     # Compile each SCSS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::SassFilter
  #   end
  class SassFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to Sass
    #   when compiling.
    attr_reader :options

    # @param [Hash] options options to pass to the Sass
    #   compiler
    # @option options [Array] :additional_load_paths a
    #   list of paths to append to Sass's :load_path.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(scss|sass)$/, '.css') }
      super(&block)

      @options = compass_options
      @options[:load_paths].concat(Array(options.delete(:additional_load_paths)))
      @options.merge!(options)
    end

    # Override {Filter#input_files}.
    #
    # We parse each input file with Sass to extract its dependencies,
    # then add the Sass::Engine (which holds the result of the parse)
    # to a cache so we don't have to reparse when it comes time to
    # actually generate the CSS.
    def input_files=(files)
      @input_files = []
      @sass_engines = {}

      files.each do |file|
        @input_files << file.with_encoding(encoding)
        engine = Sass::Engine.new(file.read, sass_options_for_file(file))
        @sass_engines[file] = engine
      end
    end

    # @param [FileWrapper] input
    #   a FileWrapper representing the Sass file whose dependencies
    #   we're finding
    # @return [Array<String>]
    #   a list of the paths that the given Fie
    def input_dependencies(input)
      @sass_engines[input].dependencies.map { |dep| dep.options[:filename] }
    end

    # Generate the Rake tasks for the output files of this filter.
    #
    # @see #outputs #outputs (for information on how the output files are determined)
    # @return [void]
    def generate_rake_tasks
      @rake_tasks = outputs.map do |output, inputs|
        dependencies = []

        inputs.each do |input|
          dependencies << input.fullpath
          dependencies += input_dependencies(input)
        end

        dependencies.each { |path| create_file_task(path) }

        create_file_task(output.fullpath, dependencies) do
          output.create { generate_output(inputs, output) }
        end
      end
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
        output.write @sass_engines.fetch(input).to_css
      end
    end

  private

    def external_dependencies
      [ 'sass', 'compass' ]
    end

    # @return the Sass options for the current Compass
    #   configuration.
    def compass_options
      Compass.add_project_configuration
      Compass.configuration.to_sass_engine_options
    end

    # @return the Sass options for the given +file+.
    #   Adds a +:syntax+ option if the filter's options
    #   don't already include one.
    def sass_options_for_file(file)
      added_opts = {
        :filename => file.fullpath,
        :syntax => file.path.match(/\.sass$/) ? :sass : :scss
      }
      added_opts.merge(@options)
    end
  end
end
