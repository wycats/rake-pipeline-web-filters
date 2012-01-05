describe "CoffeeScriptFilter" do
  CoffeeScriptFilter = Rake::Pipeline::Web::Filters::CoffeeScriptFilter

  let(:coffee_input) { <<-COFFEE }
x = 1;

y = ->
  x += 1
  COFFEE

  let(:expected_coffee_output) { <<-HTML }
(function() {
  var x, y;

  x = 1;

  y = function() {
    return x += 1;
  };

}).call(this);
  HTML

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file("input.coffee", coffee_input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter CoffeeScriptFilter.new

    filter.output_files.should == [output_file("input.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/input.js"]
    file.body.should == expected_coffee_output
    file.encoding.should == "UTF-8"
  end

  describe "naming output files" do
    it "translates .coffee extensions to .js by default" do
      filter = setup_filter CoffeeScriptFilter.new
      filter.output_files.first.path.should == "input.js"
    end

    it "accepts a block to customize output file names" do
      filter = setup_filter(CoffeeScriptFilter.new { |input| "octopus" })
      filter.output_files.first.path.should == "octopus"
    end
  end
end

