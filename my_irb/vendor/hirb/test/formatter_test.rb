require File.join(File.dirname(__FILE__), 'test_helper')

module Hirb
class FormatterTest < Test::Unit::TestCase
  def set_formatter(hash={})
    @formatter = Formatter.new(hash)
  end

  context "klass_config" do
    test "recursively merges ancestor options" do
      set_formatter "String"=>{:args=>[1,2], :options=>{:fields=>[:to_s]}},
        "Object"=>{:method=>:object_output, :ancestor=>true, :options=>{:vertical=>true}},
        "Kernel"=>{:method=>:default_output}
      expected_result = {:method=>:object_output, :args=>[1, 2], :ancestor=>true, :options=>{:fields=>[:to_s], :vertical=>true}}
      @formatter.klass_config(::String).should == expected_result
    end

    test "doesn't merge ancestor options" do
      set_formatter "String"=>{:args=>[1,2]}, "Object"=>{:method=>:object_output}, "Kernel"=>{:method=>:default_output}
      @formatter.klass_config(::String).should == {:args=>[1, 2]}
    end

    test "returns hash when nothing found" do
      set_formatter.klass_config(::String).should == {}
    end

    context "with dynamic_config" do
      after(:each) { Formatter.dynamic_config = {}}

      test "merges ancestor options and sets local config" do
        Formatter.dynamic_config = {"Object"=>{:method=>:blah}, "Kernel"=>{:args=>[1,2], :ancestor=>true}}
        set_formatter.klass_config(::String).should == {:args=>[1,2], :ancestor=>true}
        @formatter.config['Kernel'].should == {:args=>[1,2], :ancestor=>true}
      end

      test "uses local config over dynamic_config" do
        Formatter.dynamic_config = {"String"=>{:method=>:blah}}
        set_formatter "String"=>{:args=>[1,2]}
        @formatter.klass_config(::String).should == {:args=>[1,2]}
      end

      test "uses dynamic_config and sets local config" do
        Formatter.dynamic_config = {"String"=>{:method=>:blah}}
        set_formatter.klass_config(::String).should == {:method=>:blah}
        @formatter.config['String'].should == {:method=>:blah}
      end
    end
  end

  context "formatter methods:" do
    before(:all) { eval "module ::Dooda; end" }

    test "add_view sets formatter config" do
      set_formatter
      @formatter.add_view ::Dooda, :class=>"DoodaView"
      @formatter.klass_config(::Dooda).should == {:class=>"DoodaView"}
    end

    test "add_view overwrites existing formatter config" do
      set_formatter "Dooda"=>{:class=>"DoodaView"}
      @formatter.add_view ::Dooda, :class=>"DoodaView2"
      @formatter.klass_config(::Dooda).should == {:class=>"DoodaView2"}
    end

    test "parse_console_options passes all options except for formatter options into :options" do
      set_formatter
      options = {:class=>'blah', :method=>'blah', :output_method=>'blah', :blah=>'blah'}
      expected_options = {:class=>'blah', :method=>'blah', :output_method=>'blah', :options=>{:blah=>'blah'}}
      @formatter.parse_console_options(options).should == expected_options
    end
  end

  context "format_output" do
    def view_output(*args, &block); View.view_output(*args, &block); end
    def render_method(*args); View.render_method(*args); end

    def enable_with_output(value)
      Hirb.enable :output=>value
    end

    before(:all) { 
      eval %[module ::Commify
        def self.render(strings)
          strings = [strings] unless strings.is_a?(Array)
          strings.map {|e| e.split('').join(',')}.join("\n")
        end
      end]
      reset_config
    }
    before(:each) { View.formatter = nil; reset_config }
    after(:each) { Hirb.disable }
    
    test "formats with method option" do
      eval "module ::Kernel; def commify(string); string.split('').join(','); end; end"
      enable_with_output "String"=>{:method=>:commify}
      render_method.expects(:call).with('d,u,d,e')
      view_output('dude')
    end
    
    test "formats with class option" do
      enable_with_output "String"=>{:class=>"Commify"}
      render_method.expects(:call).with('d,u,d,e')
      view_output('dude')
    end
    
    test "formats with class option as symbol" do
      enable_with_output "String"=>{:class=>:auto_table}
      Helpers::AutoTable.expects(:render)
      view_output('dude')
    end

    test "formats output array" do
      enable_with_output "String"=>{:class=>"Commify"}
      render_method.expects(:call).with('d,u,d,e')
      view_output(['dude'])
    end
    
    test "formats with options option" do
      eval "module ::Blahify; def self.render(*args); end; end"
      enable_with_output "String"=>{:class=>"Blahify", :options=>{:fields=>%w{a b}}}
      Blahify.expects(:render).with('dude', :fields=>%w{a b})
      view_output('dude')
    end
    
    test "doesn't format and returns false when no format method found" do
      Hirb.enable
      render_method.expects(:call).never
      view_output(Date.today).should == false
    end
    
    test "formats with output_method option as method" do
      enable_with_output 'String'=>{:class=>"Commify", :output_method=>:chop}
      render_method.expects(:call).with('d,u,d')
      view_output('dude')
    end

    test "formats with output_method option as proc" do
      enable_with_output 'String'=>{:class=>"Commify", :output_method=>lambda {|e| e.chop}}
      render_method.expects(:call).with('d,u,d')
      view_output('dude')
    end

    test "formats output array with output_method option" do
      enable_with_output 'String'=>{:class=>"Commify", :output_method=>:chop}
      render_method.expects(:call).with("d,u,d\nm,a")
      view_output(['dude', 'man'])
    end

    test "formats with explicit class option" do
      enable_with_output 'String'=>{:class=>"Blahify"}
      render_method.expects(:call).with('d,u,d,e')
      view_output('dude', :class=>"Commify")
    end
    
    test "formats with explicit options option merges with existing options" do
      enable_with_output "String"=>{:class=>"Commify", :options=>{:fields=>%w{f1 f2}}}
      Commify.expects(:render).with('dude', :max_width=>10, :fields=>%w{f1 f2})
      view_output('dude', :options=>{:max_width=>10})
    end
  end
end
end
