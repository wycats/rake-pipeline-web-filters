module Rake::Pipeline::Web::Filters
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

  class ChainedFilter < Rake::Pipeline::Filter
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

    def generate_output(inputs, output)
      inputs.each do |input|
        output.write process_filters(input)
      end
    end

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

    def process_with_filter(input, filter_class)
      filter = filter_class.new

      output = MemoryFileWrapper.new("/output", input.path, "UTF-8")
      output.create { filter.generate_output([input], output) }

      output
    end
  end
end
