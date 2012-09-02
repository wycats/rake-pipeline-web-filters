describe "ErbFilter" do
  ErbFilter ||= Rake::Pipeline::Web::Filters::ErbFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  User = Struct.new(:name)

  let(:input) { "<%= user.name %>" }
  let(:user) { User.new "Adam" } 

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("test.html.erb", input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter ErbFilter.new(binding)
    filter.output_files.should == [output_file("test.html")]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/test.html"]
    file.body.should == user.name
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "strips .erb extensions by default" do
      filter = setup_filter ErbFilter.new
      filter.output_files.first.path.should == "test.html"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(ErbFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end
end
