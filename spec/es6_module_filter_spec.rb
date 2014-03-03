describe "ES6ModuleFilter" do
  ES6ModuleFilter ||= Rake::Pipeline::Web::Filters::ES6ModuleFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper
  MemoryManifest ||= Rake::Pipeline::SpecHelpers::MemoryManifest

  let(:input) { <<-JAVASCRIPT}
import { get, set } from 'ember';
JAVASCRIPT

  let(:expected_amd_output) { <<-JAVASCRIPT }
define(
["ember"],
function(__dependency1__) {
  "use strict";
  var get = __dependency1__.get;
  var set = __dependency1__.set;
});
JAVASCRIPT

  let(:expected_amd_with_module_id_output) { <<-JAVASCRIPT }
define("octopus",
["ember"],
function(__dependency1__) {
  "use strict";
  var get = __dependency1__.get;
  var set = __dependency1__.set;
});
JAVASCRIPT

  let(:expected_cjs_output) { <<-JAVASCRIPT }
"use strict";
var get = require("ember").get;
var set = require("ember").set;
JAVASCRIPT

  let(:expected_options_output) { <<-JAVASCRIPT }
(function(__dependency1__) {
  "use strict";
  var get = __dependency1__.get;
  var set = __dependency1__.set;
})(renamed.ember);
JAVASCRIPT

  def input_file(name, content)
    MemoryFileWrapper.new("/path/to/input", name, "UTF-8", content)
  end

  def output_file(name)
    MemoryFileWrapper.new("/path/to/output", name, "UTF-8")
  end

  # remove all whitespaces
  def should_match(expected, output)
    "#{expected}\n".gsub(/\s+/, " ").should == "#{output}\n".gsub(/\s+/, " ")
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.manifest = MemoryManifest.new
    filter.last_manifest = MemoryManifest.new
    filter.input_files = [input_file("input.js", input)]
    filter.output_root = "/path/to/output"
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates correct default amd output" do
    filter = setup_filter ES6ModuleFilter.new

    filter.output_files.should == [output_file("input.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/input.js"]
    should_match file.body, expected_amd_output
    file.encoding.should == "UTF-8"
  end

  it "generates correct default amd output with a module_id_generator" do
    filter = setup_filter ES6ModuleFilter.new(
      module_id_generator: proc { |input| "octopus" }
    )

    filter.output_files.should == [output_file("input.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/input.js"]
    should_match file.body, expected_amd_with_module_id_output
    file.encoding.should == "UTF-8"
  end

  it "generates correct cjs output" do
    filter = setup_filter ES6ModuleFilter.new({ type: "CJS" })

    filter.output_files.should == [output_file("input.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/input.js"]
    should_match file.body, expected_cjs_output
    file.encoding.should == "UTF-8"
  end

  it "generates output with optional parameters" do
    filter = setup_filter ES6ModuleFilter.new({ type: "Globals", global: "renamed"})

    filter.output_files.should == [output_file("input.js")]

    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)

    file = MemoryFileWrapper.files["/path/to/output/input.js"]
    should_match file.body, expected_options_output
    file.encoding.should == "UTF-8"
  end

  describe "invalid input" do
    # forget a curly brace
    let(:input) { <<-JAVASCRIPT }
import { get, set  from 'ember';
    JAVASCRIPT

    it "has a useful error message including the input file name" do
      filter = setup_filter ES6ModuleFilter.new
      tasks = filter.generate_rake_tasks
      lambda {
        tasks.each(&:invoke)
      }.should raise_error(ExecJS::ProgramError, "Error compiling input.js. Error: Line 1: Unexpected identifier")
    end
  end

  describe "naming output files" do
    it "accepts a block to customize output file names" do
      filter = setup_filter(ES6ModuleFilter.new { |input| "chicken" })
      filter.output_files.first.path.should == "chicken"
    end
  end
end

