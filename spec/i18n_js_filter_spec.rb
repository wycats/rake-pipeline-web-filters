# encoding: UTF-8
require 'yaml'


describe "I18nJsFilter" do
  I18nJsFilter ||= Rake::Pipeline::I18n::Filters::I18nJsFilter
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
  let(:expected_i18n_js) {
  "I18n.translations = I18n.translations || {};\nI18n.translations = {\"en\":{\"foo\":\"bar\",\"hoge\":\"hoge\"},\"ja\":{\"foo\":\"バー\",\"hoge\":\"ホゲ\"}};"
  }
  def input_file(name, content)
    MemoryFileWrapper.new('/path/to/input', name, 'UTF-8', content)
  end

  def output_file(name)
    MemoryFileWrapper.new('/path/to/output', name, 'UTF-8')
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file('i18n_js_localizations.yml', input)]
    filter.output_root = '/path/to/output'
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates i18n_js" do
    filter = setup_filter I18nJsFilter.new
    filter.output_files.should == [output_file('i18n_js_localizations.js')]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files['/path/to/output/i18n_js_localizations.js']
    file.body.should == expected_i18n_js
  end

end
