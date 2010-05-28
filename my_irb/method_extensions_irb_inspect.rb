class Method
  alias_method :inspect, :irb_inspect if method_defined?(:irb_inspect)
end

class UnboundMethod
  alias_method :inspect, :irb_inspect if method_defined?(:irb_inspect)
end
