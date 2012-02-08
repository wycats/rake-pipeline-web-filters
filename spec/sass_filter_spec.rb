describe "SassFilter" do
  SassFilter ||= Rake::Pipeline::Web::Filters::SassFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

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

  def expected_css_output(filename)
    <<-CSS
/* line 3, #{filename} */
.border {
  border-color: #3bbfce;
}
CSS
  end

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter, input_files=nil)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = input_files || [input_file("border.scss", scss_input)]
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
    file.body.should == expected_css_output("/path/to/input/border.scss")
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
    input_files = [input_file("border.sass_file", sass_input)]
    filter = setup_filter(SassFilter.new(:syntax => :sass), input_files)
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.sass_file"]
    file.body.should == expected_css_output("/path/to/input/border.sass_file")
  end

  it "compiles files with a .sass extension as sass" do
    input_files = [input_file("border.sass", sass_input)]
    filter = setup_filter(SassFilter.new, input_files)
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output("/path/to/input/border.sass")
  end

  it "passes Compass's options to the Sass compiler" do
    Compass.configuration do |c|
      c.preferred_syntax = :sass
    end

    input_files = [input_file("border.css", scss_input)]
    filter = setup_filter(SassFilter.new, input_files)
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output("/path/to/input/border.css")
  end

  it "adds @imported files as dependencies of the base file" do
    inputs = {
      "base.scss" => '@import "border";',
      "_border.scss" => scss_input
    }

    inputs.each do |file, contents|
      File.open(File.join(tmp, file), "w") { |f| f.write(contents) }
    end

    filter = SassFilter.new
    filter.input_files = [Rake::Pipeline::FileWrapper.new(tmp, "base.scss")]
    filter.output_root = tmp
    filter.rake_application = Rake::Application.new
    tasks = filter.generate_rake_tasks

    tasks.first.prerequisites.should include(File.join(tmp, "_border.scss"))
  end
end
