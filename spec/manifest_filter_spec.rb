describe "ManifestFilter" do
  ManifestFilter ||= Rake::Pipeline::Web::Filters::ManifestFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [
      input_file("manifest/index.html", ""),
      input_file("manifest/application.js", ""),
      input_file("manifest/application.css", "")
    ]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates a proper cache manifest for output" do
    filter = setup_filter ManifestFilter.new("cache.manifest")

    filter.output_files.should == [output_file("cache.manifest")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/cache.manifest"]

    file.encoding.should == "UTF-8"

    file.body.lines.first.chomp.should == 'CACHE MANIFEST'

    file.body.should match(%r{# Tag: \d+})

    file.body.should match(/^index\.html/)
    file.body.should match(/^application\.css/)
    file.body.should match(/^application\.js/)
  end

  describe "naming output files" do
    it "should use cache.manifest by default" do
      filter = setup_filter ManifestFilter.new
      filter.output_files.first.path.should == "cache.manifest"
    end

    it "accepts a string to set the output file name" do
      filter = setup_filter(ManifestFilter.new("octopus"))
      filter.output_files.first.path.should == "octopus"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(ManifestFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end
end
