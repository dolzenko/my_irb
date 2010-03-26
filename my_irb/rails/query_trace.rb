$LOAD_PATH.unshift(File.join(MyIrb.root, "my_irb/vendor/query_trace/lib"))

module MyIrb::Rails
  module QueryTrace
    def query_trace
      require "query_trace"
      ::QueryTrace.toggle!
    end
  end
end