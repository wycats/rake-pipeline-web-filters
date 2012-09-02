describe "IifeFilter" do
  IifeFilter ||= Rake::Pipeline::Web::Filters::IifeFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:js_input) { <<-HERE }
var name = "Truckasaurus Gates";
HERE

  let(:expected_js_output) { <<-HERE }
(function() {
var name = "Truckasaurus Gates";
})();
HERE

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("name.js", js_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter IifeFilter.new

    filter.output_files.should == [output_file("name.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/name.js"]
    file.body.should == expected_js_output.chomp
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .js extensions to .min.js by default" do
      filter = setup_filter IifeFilter.new
      filter.output_files.first.path.should == "name.js"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(IifeFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end
end
