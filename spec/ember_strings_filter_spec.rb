# encoding: UTF-8
require 'yaml'


describe "EmberStringsFilter" do
  EmberStringsFilter ||= Rake::Pipeline::I18n::Filters::EmberStringsFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  # Seems like YAML is expecting this method.
  MemoryFileWrapper.class_eval( 'def external_encoding; Encoding.default_external; end')

  let(:input) { yaml = <<EOF
# encoding: UTF-8
en:
  foo: bar
  hoge: hoge
ja:
  foo: バー
  hoge: ホゲ
EOF
  }

  # not using heredoc as it adds an extra \n to the end
  let(:expected_ember_strings) {
  "EmberI18n = EmberI18n || {};EmberI18n['en'] = { 'foo' : 'bar','hoge' : 'hoge' };EmberI18n['ja'] = { 'foo' : 'バー','hoge' : 'ホゲ' };"
  }
  def input_file(name, content)
    MemoryFileWrapper.new('/path/to/input', name, 'UTF-8', content)
  end

  def output_file(name)
    MemoryFileWrapper.new('/path/to/output', name, 'UTF-8')
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file('localizations.yml', input)]
    filter.output_root = '/path/to/output'
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates ember_strings" do
    filter = setup_filter EmberStringsFilter.new
    filter.output_files.should == [output_file('localizations.js')]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files['/path/to/output/localizations.js']
    file.body.should == expected_ember_strings
  end

end

