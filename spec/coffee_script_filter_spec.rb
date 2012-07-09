describe "CoffeeScriptFilter" do
  CoffeeScriptFilter ||= Rake::Pipeline::Web::Filters::CoffeeScriptFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

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

  let(:expected_unwrapped_coffee_output) { <<-HTML }
var x, y;

x = 1;

y = function() {
  return x += 1;
};
  HTML

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  def should_match(expected, output)
    "#{expected}\n".gsub(/\n+/, "\n").should == "#{output}\n".gsub(/\n+/, "\n")
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
    should_match file.body, expected_coffee_output
    file.encoding.should == "UTF-8"
  end

  it "generates unwrapped output" do
    filter = setup_filter CoffeeScriptFilter.new(:no_wrap => true)

    filter.output_files.should == [output_file("input.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/input.js"]
    should_match file.body, expected_unwrapped_coffee_output
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

  describe "invalid input" do
    let(:coffee_input) { <<-COFFEE }
y = function(){
  return "whoops there javascript in here!"
}
    COFFEE

    it "has a useful error message including the input file name" do
      filter = setup_filter CoffeeScriptFilter.new
      tasks = filter.generate_rake_tasks
      lambda {
        tasks.each(&:invoke)
      }.should raise_error(ExecJS::RuntimeError, /Error compiling input.coffee.+line 1/i)
    end
  end

end

