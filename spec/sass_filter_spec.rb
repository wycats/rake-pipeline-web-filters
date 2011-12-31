describe "SassFilter" do
  SassFilter = Rake::Pipeline::Web::Filters::SassFilter

  let(:scss_input) { <<-SCSS }
$blue: #3bbfce;

.border {
  border-color: $blue;
}
SCSS

  let(:sass_input) { <<-SASS }
$blue: #3bbfce

.border
  border-color: $blue
SASS

  let(:expected_css_output) { <<-CSS }
/* line 3 */
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
    filter.input_files = [input_file("border.scss", scss_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter SassFilter.new

    filter.output_files.should == [output_file("border.css")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .scss extensions to .css by default" do
      filter = setup_filter SassFilter.new
      filter.output_files.first.path.should == "border.css"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(SassFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end

  it "accepts options to pass to the Sass compiler" do
    filter = setup_filter(SassFilter.new(:syntax => :sass))
    filter.input_files = [input_file("border.sass_file", sass_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.sass_file"]
    file.body.should == expected_css_output
  end

  it "compiles files with a .sass extension as sass" do
    filter = setup_filter(SassFilter.new)
    filter.input_files = [input_file("border.sass", sass_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output
  end

  it "passes Compass's options to the Sass compiler" do
    Compass.configuration do |c|
      c.preferred_syntax = :sass
    end

    filter = setup_filter(SassFilter.new)
    filter.input_files = [input_file("border.css", scss_input)]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output
  end
end
