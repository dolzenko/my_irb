namespace :extconf do
  desc "Compiles the Ruby extension"
  task :compile
end

task :compile => "extconf:compile"

task :test => :compile

BIN = "*.{bundle,jar,so,obj,pdb,lib,def,exp}"
