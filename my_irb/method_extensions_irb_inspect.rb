$LOAD_PATH.unshift(File.join(MyIrb.root, "my_irb/vendor/method_extensions/lib"))
$LOAD_PATH.unshift(File.join(MyIrb.root, "my_irb/vendor/CodeRay/lib"))

require "method_extensions"
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

## rest is stolen from http://github.com/davidrichards/sirb
# Failed experiment, redefining `[]` on something as ubiquitous as Symbol and
# Module is really bad idea and screws up error messages a lot.
#
#class Symbol
#  # Add [] and []= operators to the Symbol class for accessing and setting
#  # singleton methods of objects. Read : as "method" and [] as "of".
#  # So :m[o] reads "method m of o".
#
#  # Return the Method of obj named by this symbol. This may be a singleton
#  # method of obj (such as a class method) or an instance method defined
#  # by obj.class or inherited from a superclass.
#  # Examples:
#  #   creator = :new[Object]  # Class method Object.new
#  #   doubler = :*[2]         # * method of Fixnum 2
#  #
#  def [](obj)
#    obj.method(self)
#  end
#end
#
#class Module
#  alias [] instance_method
#end
