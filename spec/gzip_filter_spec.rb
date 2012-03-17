require 'base64'
require 'stringio'
require 'zlib'

describe "GzipFilter" do
  GzipFilter ||= Rake::Pipeline::Web::Filters::GzipFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:input) { "(function(){console.log('gzip me')})();" }

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "BINARY")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("test.js", input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter GzipFilter.new
    filter.output_files.should == [output_file("test.js.gz")]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/test.js.gz"]
    Zlib::GzipReader.new(StringIO.new(file.body)).read.should == input
  end

  describe "naming output files" do
    it "translates extensions to .*.gz by default" do
      filter = setup_filter GzipFilter.new
      filter.output_files.first.path.should == "test.js.gz"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(GzipFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

end

