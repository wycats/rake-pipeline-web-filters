describe "YUICssFilter" do
  YUICssFilter ||= Rake::Pipeline::Web::Filters::YUICssFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:css_input) { <<-HERE }
div.error {
  color: red;
}
div.warning {
  display: none;
}
HERE

  let(:expected_css_output) {
    'div.error{color:red}div.warning{display:none}'
  }

  let(:expected_linebreak_css_output) {
    %[div.error{color:red}\ndiv.warning{display:none}]
  }

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("error.css", css_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter YUICssFilter.new

    filter.output_files.should == [output_file("error.min.css")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/error.min.css"]
    file.body.should == expected_css_output
    file.encoding.should == "UTF-8"
  end

  it "skips files named .min" do
    filter = setup_filter YUICssFilter.new

    filter.input_files = [input_file("error.min.css", "fake-css")]

    filter.output_files.should == [output_file("error.min.css")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/error.min.css"]
    file.body.should == "fake-css"
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .css extensions to .min.css by default" do
      filter = setup_filter YUICssFilter.new
      filter.output_files.first.path.should == "error.min.css"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(YUICssFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "accepts options to pass to the YUI compressor" do
    filter = setup_filter(YUICssFilter.new(:line_break => 0))
    filter.input_files = [input_file("error.css", css_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/error.min.css"]
    file.body.should == expected_linebreak_css_output
  end

end

