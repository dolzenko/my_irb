module MyIrb::Rails
  module Misc
    def r!
      reload!
    end
    
    def sql(s)
      ActiveRecord::Base.connection.execute s
    end
  end
end