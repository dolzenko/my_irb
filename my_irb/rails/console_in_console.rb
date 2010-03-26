module MyIrb::Rails
  # Brings some most often used shell commands to script/console prompt
  module ConsoleInConsole
    def about
      require "rails/info"
      Rails::Info
    end

    %w(model controller scaffold migration).each do |generatable|
      define_method(generatable) do |str|
        generate("#{ generatable } #{ str }")
      end

      define_method("destroy_#{ generatable }") do |str|
        destroy("#{ generatable } #{ str }")
      end
    end

    def migrate
      rake "db:migrate"
    end

    if ::Rails::VERSION::MAJOR == 2
      def generate(*args)
        begin
          require "rails_generator"
          require "rails_generator/scripts/generate"
          if args.size == 1 && args[0].is_a?(String)
            Rails::Generator::Scripts::Generate.new.run(args[0].split)
          end
        rescue Exception => e
          puts "Exception while running generator: #{ e.inspect }"
        end
        nil
      end

      def destroy(*args)
        require "rails_generator"
        require "rails_generator/scripts/destroy"
        begin
          Rails::Generator::Scripts::Destroy.new.run(args[0].split)
        rescue Exception => e
          puts "Exception while running destroy: #{ e.inspect }"
        end
        nil
      end

      def rake(task)
        require "rake/testtask"
        require "rake/rdoctask"
        require "tasks/rails"
        Rake::Task[task].execute # need +execute+ instead +invoke+ (invoke invokes the task only once)
        nil # return value will be something meaningless anyway
      end
      
    elsif ::Rails::VERSION::MAJOR == 3
      def generate(cmd)
        require "rails/generators"
        ARGV.replace(cmd.split)
        load "rails/commands/generate.rb"
        nil # return value will be something meaningless anyway
      end

      def destroy(cmd)
        require "rails/generators"
        ARGV.replace(cmd.split)
        load "rails/commands/destroy.rb"
        nil
      end

      def rake(task)
        load(Rails.root + "Rakefile")
        Rake::Task[task].execute # need +execute+ instead +invoke+ (invoke invokes the task only once)
        nil
      end
    end
  end
end