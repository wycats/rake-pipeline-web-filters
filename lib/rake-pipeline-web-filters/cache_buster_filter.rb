module Rake::Pipeline::Web::Filters
  # A filter that inserts a cache-busting key into the outputted file name.
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets"
  #     output "public"
  #
  #     filter Rake::Pipeline::Web::Filters::CacheBusterFilter
  #   end
  class CacheBusterFilter < Rake::Pipeline::Filter

    # @return [Proc] the default cache key generator, which
    #   takes the MD5 hash of the input's file name and contents.
    DEFAULT_KEY_GENERATOR = proc { |input|
      require 'digest/md5'
      Digest::MD5.new << input.path << input.read
    }

    # @param [Proc] key_generator a block to use as the Filter's method of
    #   turning input file wrappers into cache keys; defaults to
    #   +DEFAULT_KEY_GENERATOR+
    def initialize(&key_generator)
      key_generator ||= DEFAULT_KEY_GENERATOR
      output_name_generator = proc { |path, file|
        parts = path.split('.')
        index_to_modify = parts.length > 1 ? -2 : -1
        parts[index_to_modify] << "-#{key_generator.call(file)}"
        parts.join('.')
      }
      super(&output_name_generator)
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        output.write input.read
      end
    end

  end
end
