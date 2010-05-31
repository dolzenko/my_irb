require "coderay"
require "coderay/encoders/term"
# override color scheme provided by CodeRay::Encoders::Term
CodeRay::Encoders::Term::TOKEN_COLORS[:constant] = ['36', '4'] # cyan instead of unintelligible blue

class Method
  alias_method :inspect, :irb_inspect if method_defined?(:irb_inspect)
end

class UnboundMethod
  alias_method :inspect, :irb_inspect if method_defined?(:irb_inspect)
end
