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
  hoge: ホゲ
EOF
  }

  # not using heredoc as it adds an extra \n to the end
  let(:expected_js) { "if(I18n == undefined) {
 var I18n = {
       set_locale : function(locale) {
                      Ember.STRINGS = this[locale]
                    }
       }
};
I18n['en'] = { 'foo' : 'bar','hoge' : 'ホゲ' }"
  }

  def input_file(name, content)
    MemoryFileWrapper.new('/path/to/input', name, 'UTF-8', content)
  end

  def output_file(name)
    MemoryFileWrapper.new('/path/to/output', name, 'UTF-8')
  end

  def setup_filter(filter)
    filter.file_wrapper_class = MemoryFileWrapper
    filter.input_files = [input_file('en.yml', input)]
    filter.output_root = '/path/to/output'
    filter.rake_application = Rake::Application.new
    filter
  end

  it "generates output" do
    filter = setup_filter EmberI18nFilter.new
    filter.output_files.should == [output_file('en.js')]
    tasks = filter.generate_rake_tasks
    tasks.each(&:invoke)
    file = MemoryFileWrapper.files['/path/to/output/en.js']
    file.body.should == expected_js
  end
end
