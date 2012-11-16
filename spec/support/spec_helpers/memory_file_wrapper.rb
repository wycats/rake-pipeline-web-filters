class Rake::Pipeline
  module SpecHelpers
    class MemoryFileWrapper < Struct.new(:root, :path, :encoding, :body)
      @@files = {}
      @@data = {}

      def self.files
        @@files
      end

      def self.data
        @@data
      end

      def with_encoding(new_encoding)
        self.class.new(root, path, new_encoding, body)
      end

      def fullpath
        File.join(root, path)
      end

      def create
        @@files[fullpath] = self
        self.body = ""
        yield
      end

      def read
        body || @@data[fullpath] || ""
      end

      def write(contents)
        self.body << contents
      end
    end
  end
end
