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
/* line 3, /path/to/input/#{filename} */
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
    file.body.should == expected_css_output("border.scss")
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
    file.body.should == expected_css_output("border.sass_file")
  end

  it "compiles files with a .sass extension as sass" do
    input_files = [input_file("border.sass", sass_input)]
    filter = setup_filter(SassFilter.new, input_files)
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files["/path/to/output/border.css"]
    file.body.should == expected_css_output("border.sass")
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
    file.body.should == expected_css_output("border.css")
  end

  it "generates rake tasks for files within additional load path" do
    touch_p("additional/styles.css")
    filter = setup_filter(SassFilter.new(:additional_load_paths => "additional"))

    tasks = filter.generate_rake_tasks

    prerequisite_names = tasks.first.prerequisite_tasks.map { |p| p.name }

    prerequisite_names.should include("additional/styles.css")
  end

  describe "additional load paths" do
    it "is empty by default" do
      filter = setup_filter(SassFilter.new)
      filter.additional_load_paths == []
    end

    it "transforms to array" do
      filter = setup_filter(SassFilter.new(:additional_load_paths => "additional"))
      filter.additional_load_paths == ["additional"]
    end

    it "accepts array" do
      filter = setup_filter(SassFilter.new(:additional_load_paths => ["additional", "extra"]))
      filter.additional_load_paths == ["additional", "extra"]
    end
  end

  describe "additional file paths" do
    it "includes all nested files" do
      touch_p("additional/styles.css")
      touch_p("additional/nested/styles.css")
      filter = setup_filter(SassFilter.new(:additional_load_paths => "additional"))

      filter.additional_dependencies.should include("additional/styles.css")
      filter.additional_dependencies.should include("additional/nested/styles.css")
    end

    it "works with tralling slash" do
      touch_p("additional/nested/styles.css")
      filter = setup_filter(SassFilter.new(:additional_load_paths => "additional/"))

      filter.additional_dependencies.should include("additional/nested/styles.css")
    end

    it "includes files from different load paths" do
      touch_p("additional/styles.css")
      touch_p("extra/styles.css")
      filter = setup_filter(SassFilter.new(:additional_load_paths => ["additional", "extra"]))

      filter.additional_dependencies.should include("additional/styles.css")
      filter.additional_dependencies.should include("extra/styles.css")
    end
  end
end
