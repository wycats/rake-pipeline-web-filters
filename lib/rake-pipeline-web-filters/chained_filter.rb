module Rake::Pipeline::Web::Filters
  # Implement the FileWrapper API. Because filters are defined
  # in terms of the FileWrapper API, we can implement an
  # alternative that doesn't write to disk but still utilizes
  # the same filter definitions.
  class MemoryFileWrapper < Struct.new(:root, :path, :encoding, :body)
    def with_encoding(new_encoding)
      self.class.new(root, path, new_encoding, body)
    end

    def fullpath
      File.join(root, path)
    end

    def create
      self.body = ""
      yield
    end

    alias read body

    def write(contents)
      self.body << contents
    end
  end

  # The purpose of ChainedFilter is to enable filters to
  # be applied to files based upon their file extensions.
  #
  # Filters are applied repeatedly to files for each
  # extension.
  #
  # @example
  #
  #   filter ChainedFilter, :types => {
  #     :erb => ErbFilter,
  #     :coffee => CoffeeFilter,
  #     :scss => ScssFilter
  #   }
  #
  # In this example, files with the extensions +erb+,
  # +coffee+, and +scss+ will be processed using the
  # specified filters. If a file has multiple extensions,
  # all of the filters will be applied.
  #
  # For example, with the above filter specification,
  # a file like +application.js.coffee.erb+ will first
  # apply the +ErbFilter+, then the +CoffeeFilter+, and
  # then output +application.js+.
  #
  # This filter is largely designed for use with the
  # {ProjectHelpers#register register} helper, which
  # will transparently add a ChainedFilter before each
  # input block with the registered extensions.
  class ChainedFilter < Rake::Pipeline::Filter
    attr_reader :filters

    # @param [Hash] options
    # @option options [Hash] :types
    #   A hash of file extensions and their associated
    #   filters. See the class description for more
    #   information.
    def initialize(options={}, &block)
      @filters = options[:types]

      keys = @filters.keys
      pattern = keys.map { |key| "\\.#{key}" }.join("|")
      @pattern = Regexp.new("(#{pattern})*$", "i")

      block ||= proc do |input|
        input.sub(@pattern, '')
      end

      super(&block)
    end

    # @private
    #
    # Implement +generate_output+
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write process_filters(input)
      end
    end

    # @private
    #
    # Process an input file by applying the filter for each
    # extension in the file.
    def process_filters(input)
      keys = input.path.match(@pattern)[0].scan(/(?<=\.)\w+/)

      filters = keys.reverse_each.map do |key|
        @filters[key.to_sym]
      end

      filters.each do |filter|
        input = process_with_filter(input, filter)
      end

      input.read
    end

    # @private
    #
    # Process an individual file with a filter.
    def process_with_filter(input, filter_class)
      filter = filter_class.new

      output = MemoryFileWrapper.new("/output", input.path, "UTF-8")
      output.create { filter.generate_output([input], output) }

      output
    end
  end
end
