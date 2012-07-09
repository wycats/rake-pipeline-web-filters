# encoding: UTF-8
require 'yaml'


describe "EmberI18nFilter" do
  EmberI18nFilter ||= Rake::Pipeline::Web::Filters::EmberI18nFilter
  MemoryFileWrapper ||= Rake::Pipeline::SpecHelpers::MemoryFileWrapper

  # Seems like YAML is expecting this method so.  
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
  let(:expected_ember_i18n_js) {
    "var EmberI18n = { set_locale : function(locale) {\n                                        strings = this[locale]\n                                        if(strings) { Ember.STRINGS = strings }\n                                      },\n                                      'en': { 'foo' : 'bar','hoge' : 'hoge' },'ja': { 'foo' : 'バー','hoge' : 'ホゲ' }\n      };"
  }
  let(:expected_i18n_js) {
    'window.i18n.translations = {"en":{"foo":"bar","hoge":"hoge"},"ja":{"foo":"バー","hoge":"ホゲ"}}'
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

  it "generates ember_i18n output by default" do
    filter = setup_filter EmberI18nFilter.new
    filter.output_files.should == [output_file('localizations.js')]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files['/path/to/output/localizations.js']
    file.body.should == expected_ember_i18n_js
  end

  it "generates i18n_js output by option" do
    filter = setup_filter EmberI18nFilter.new(:use_i18n_js => true)
    filter.output_files.should == [output_file('localizations.js')]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files['/path/to/output/localizations.js']
    file.body.should == expected_i18n_js
  end

end
