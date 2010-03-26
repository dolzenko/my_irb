$LOAD_PATH.unshift(File.join(MyIrb.root, "my_irb/vendor/hirb/lib"))

module MyIrb::Rails
  module Hirb
    def table(output, options={})
      require "hirb"
      ::Hirb::Console.render_output(output, options.merge(:class=>"Hirb::Helpers::AutoTable"))
    end

    def hirb
      require "hirb"
      if @@is_on = !(defined?(@@is_on) && @@is_on)
        ::Hirb.enable
      else
        ::Hirb.disable
      end
    end
  end
end