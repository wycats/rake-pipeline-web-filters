module Rake::Pipeline::I18n::Filters
  # A mixin for filters that have dependencies on external
  # libraries. Include this module in the filter class and
  # declare a private `external_dependencies` method that
  # returns an array of strings. Each one will be passed
  # to `Kernel#require` when an instance of the filter
  # is created.
  module FilterWithDependencies

    def initialize(*args, &block)
      require_dependencies!
      super(*args, &block)
    end

    private

    def require_dependencies!
      external_dependencies.each do |d|
        begin
          require d
        rescue LoadError => error
          raise error, "#{self.class} requires #{d}, but it is not available."
        end
      end
    end
  end
end
