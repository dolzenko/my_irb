#!/usr/bin/env ruby

irb_rc = File.join(ENV["HOME"], ".irbrc")

if File.exist?(irb_rc)
  warn "Failed to install: #{ irb_rc } already exists"
else
  system *%W(ln -v #{ File.expand_path(".irbrc", File.dirname(__FILE__)) } #{ irb_rc })
end