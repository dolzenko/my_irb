module MyIrb
  extend self
  
  def main
    init_rubygems
    require "English"
    save_history
    setup_after_initialize_hook
  end

  def after_initialize(context)
    load_extensions(context)
    rejoice
  end

  def init_rubygems
    begin
      require "rubygems"
    rescue LoadError => err
      warn "Couldn't load RubyGems: #{err}"
    end
  end

  def save_history
    require "irb/ext/save-history"
    IRB.conf[:SAVE_HISTORY] = 100
    IRB.conf[:HISTORY_FILE] = File.join(ENV['HOME'], ".irb-save-history") 
  end

  def init_hirb
    
  end

  def rejoice
    puts "MyIrb loaded"
  end

  def setup_after_initialize_hook
    IRB.conf[:IRB_RC] = MyIrb.method(:after_initialize)
  end

  def load_extensions(context)
    extension_dirs = [ "#{ root }/my_irb/*.rb" ]
    extension_dirs << "#{ root }/my_irb/rails/*.rb" if defined?(Rails)

    @@context = context

    for extension in extension_dirs.map(&Dir.method(:glob)).flatten
      require(extension)
      
      if (mod = extension_module(extension)).instance_of?(Module)
        context.main.extend(mod)
      end
    end
  end

  def context
    @@context
  end

  def root
    File.expand_path("../", __FILE__)
  end

  def extension_module(extension_file_name)
    root_based_name = extension_file_name.sub(/^#{ Regexp.escape root }/, "").sub(/\.rb$/, "")
    MyIrb::ActiveSupport::Inflector.constantize(MyIrb::ActiveSupport::Inflector.camelize(root_based_name))
  rescue NameError
  end
end

MyIrb.main
