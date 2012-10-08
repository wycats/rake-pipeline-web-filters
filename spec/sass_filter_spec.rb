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

  describe "additional dependencies" do
    def write_input_file(filename, contents='', root=tmp)
      mkdir_p root
      File.open(File.join(root, filename), 'w') { |f| f.puts contents }
      Rake::Pipeline::FileWrapper.new(root, filename)
    end

    let(:main_scss) { '@import "blue";' }
    let(:blue_scss) { '$blue: #3bbfce;' }
    let!(:main) { write_input_file('main.scss', main_scss) }
    let!(:blue) { write_input_file('blue.scss', blue_scss) }

    let(:fixtures_path) { File.expand_path("../fixtures", __FILE__) }
    let(:sandbox_path) { File.expand_path("../sandbox", __FILE__) }

    before do
      File.open(main.fullpath, "w") { |f| f.puts main_scss }
      File.open(blue.fullpath, "w") { |f| f.puts blue_scss }

      FileUtils.mkdir_p sandbox_path
    end

    after do
      FileUtils.rm_rf sandbox_path
    end

    it "includes @imported files" do
      filter = SassFilter.new
      filter.input_files = [main]
      filter.output_root = "#{tmp}/output"
      filter.rake_application = Rake::Application.new

      filter.additional_dependencies(main).should include(blue.fullpath)

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)
    end

    it "should expand sprite imports using the compass load path" do
      Compass.reset_configuration!
      Compass.configuration.sprite_load_path << sandbox_path

      FileUtils.mkdir "#{sandbox_path}/icons"

      FileUtils.cp "#{fixtures_path}/icon.png", "#{sandbox_path}/icons/icon1.png"
      FileUtils.cp "#{fixtures_path}/icon.png", "#{sandbox_path}/icons/icon2.png"

      sprites = write_input_file 'sprites.scss', <<-scss
        @import "icons/*.png";
        @include all-icons-sprites;
      scss

      filter = SassFilter.new
      filter.input_files = [sprites]
      filter.output_root = "#{tmp}/output"
      filter.rake_application = Rake::Application.new

      tasks = filter.generate_rake_tasks
      tasks.each(&:invoke)

      filter.additional_dependencies(sprites).should include("#{sandbox_path}/icons/icon1.png")
      filter.additional_dependencies(sprites).should include("#{sandbox_path}/icons/icon2.png")
    end
  end
end
