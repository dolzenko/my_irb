module MyIrb
  extend self
  
  def main
    init_rubygems
    require "English"
    require "pp"
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
      warn "Couldn't load RubyGems: #{ err }"
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
    # use Pathname.new(__FILE__).realpath here
    real_irbrc_path = if File.symlink?(__FILE__)
      File.expand_path(File.readlink(__FILE__), File.dirname(__FILE__))
    else
      __FILE__
    end
    File.expand_path("../", real_irbrc_path)
  end

  def extension_module(extension_file_name)
    require(File.join(root, "active_support_ripoffs"))
    root_based_name = extension_file_name.sub(/^#{ Regexp.escape root }/, "").sub(/\.rb$/, "")
    MyIrb::ActiveSupport::Inflector.constantize(MyIrb::ActiveSupport::Inflector.camelize(root_based_name))
  rescue NameError
  end

  def self.gem(name)
    loader = proc { require name }

    fixers = []

    if defined?(Bundler)
      # break out of Bundler jail rudely
      # http://github.com/carlhuda/bundler/issues/#issue/183/comment/225440
      fixers << proc do
        Gem.refresh
        Gem.activate(name)
      end
    end
    
    fixers << proc do
      cmd = "gem install #{ name } || gem install --user-install #{ name }"
      warn "#{ name } gem not installed, trying to install with: #{ cmd }"

      if system(cmd)
        Gem.refresh
        Gem.activate(name)
      else
        warn "#{ name } gem installation failed"
      end
    end

    begin
      loader.call
    rescue Exception
      if fixer = fixers.shift
        begin
          fixer.call # try to fix and retry
        rescue Exception # ignore errors in fixers
        end
        retry
      else
        # no more fixers left, exiting
        warn "failed to require #{ name } gem"
        return false
      end
    end

    block_given? ? yield : true
  end
end

MyIrb.main
