require "pry"
require "rake-pipeline"
require "rake-pipeline-web-filters"

require "support/spec_helpers/file_utils"
require "support/spec_helpers/filters"
require "support/spec_helpers/input_helpers"
require "support/spec_helpers/memory_file_wrapper"
require "support/spec_helpers/memory_manifest"

RSpec.configure do |config|
  original = Dir.pwd

  config.include Rake::Pipeline::SpecHelpers::FileUtils

  def tmp
    File.expand_path("../tmp", __FILE__)
  end

  config.before do
    rm_rf(tmp)
    mkdir_p(tmp)
    Dir.chdir(tmp)
  end

  config.after do
    Dir.chdir(original)
  end
end
