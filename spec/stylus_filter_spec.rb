describe "StylusFilter" do
  StylusFilter ||= Rake::Pipeline::Web::Filters::StylusFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  let(:styl_input) { <<-STYLUS }
border-radius()
  -webkit-border-radius arguments
  -moz-border-radius arguments
  border-radius arguments
  
body
  font 12px Helvetica, Arial, sans-serif
  
a.button
  border-radius 5px
STYLUS

  let(:expected_css_output) { <<-CSS }
body {
  font: 12px Helvetica, Arial, sans-serif;
}
a.button {
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
}
CSS

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter, input=styl_input)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("border.styl", input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter StylusFilter.new

    filter.output_files.should == [output_file("border.css")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .styl extensions to .css by default" do
      filter = setup_filter StylusFilter.new
      filter.output_files.first.path.should == "border.css"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(StylusFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end
end
