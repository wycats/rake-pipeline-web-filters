describe "LessFilter" do
  LessFilter ||= Rake::Pipeline::Web::Filters::LessFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:less_input) { <<-SCSS }
@blue: #3bbfce;

.border {
  border-color: @blue;
}
SCSS

  let(:expected_css_output) { <<-CSS }
.border {
  border-color: #3bbfce;
}
CSS

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("border.less", less_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter LessFilter.new

    filter.output_files.should == [output_file("border.css")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .less extensions to .css by default" do
      filter = setup_filter LessFilter.new
      filter.output_files.first.path.should == "border.css"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(LessFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end
end
