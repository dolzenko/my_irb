module MyIrb::Rspec
  def generate_spec(class_path)
    require 'fileutils'

    parts = class_path.split(/[\\\/]/)

    if parts.include?("lib")
      project_root = parts[0 .. parts.index('lib') - 1].join("/")

      class_path = parts[parts.index('lib') .. -2].join("/")

      class_file_path = parts[parts.index('lib') + 1 .. -1].join("/")

      spec_name = File.basename(parts[-1]).sub(/\.rb$/, "_spec.rb")

      FileUtils.mkdir_p(File.join(project_root, "spec", class_path))

      spec_path = File.join(project_root, "spec", class_path, spec_name)

      raise "#{ spec_path } already exists" if File.exist?(spec_path)

      spec_class_name = camelize class_file_path.sub(/\.rb$/, "")

      File.open(spec_path, "w") do |f|
        f.puts "require \"#{ class_file_path.sub(/\.rb$/, "") }\""
        f.puts ""
        f.puts "describe #{ spec_class_name } do"
        f.puts "end"
      end

      puts "#{ spec_path } generated"
    else
      raise "Don't know how to generate spec for #{ class_path }"
    end
  end
end