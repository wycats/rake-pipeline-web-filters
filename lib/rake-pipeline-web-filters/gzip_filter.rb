require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that gzips input files using zlib
  #
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Compress each JS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::GzipFilter
  #   end
  class GzipFilter < Rake::Pipeline::Filter

    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    processes_binary_files

    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(&block)
      block ||= proc { |input| input.sub(/\.(.*)$/, '.\1.gz') }
      super(&block)
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compresses each input file with
    # Zlib.GzipWriter.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        # gzip input file to stream
        fakefile = StringIO.new
        gz = Zlib::GzipWriter.new(fakefile)
        gz.write(input.read)
        gz.close

        # send gzipped contents to output
        output.write fakefile.string
      end
    end

  private

    def external_dependencies
      [ 'stringio', 'zlib' ]
    end
  end
end

