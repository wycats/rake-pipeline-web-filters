describe "RoyFilter" do
  let(:file_wrapper_class){Rake::Pipeline::SpecHelpers::MemoryFileWrapper}
  let(:rake_app){Rake::Application.new}

  let(:encoding){"UTF-8"}
  let(:input_path){"/in"}
  let(:output_path){"/out"}
  let(:input_name){"a.roy"}
  let(:output_name){"a.js"}

  let(:input_file){file_wrapper_class.new(input_path, input_name, encoding, input)}
  let(:output_file){file_wrapper_class.new(output_path, output_name, encoding)}

  subject {
    filter = Rake::Pipeline::Web::Filters::RoyFilter.new(options)
    filter.file_wrapper_class = file_wrapper_class
    filter.input_files = [input_file]
    filter.output_root = output_path
    filter.rake_application = rake_app
    filter
  }

  describe "#generate_output" do
    context "when default options are used" do
      let(:options){{}}
      let(:output){<<-JS.gsub(/^\s*/,"")
          (function() {
            var x = 10;
          })();
        JS
      }
      context "when the input is valid" do
        let(:input){"let x = 10"}
        before{subject.generate_rake_tasks.each(&:invoke)}
        specify{subject.output_files.should == [output_file]}
        specify{file_wrapper_class.files["#{output_path}/#{output_name}"].body.should == output}
        specify{file_wrapper_class.files["#{output_path}/#{output_name}"].encoding.should == encoding}
      end
      context "when the input is invalid" do
        let(:input){"var = x, 10"}
        specify{->{subject.generate_rake_tasks.each(&:invoke)}.should raise_error}
      end
    end
  end
end
