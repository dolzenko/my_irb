module ActiveRecord
  class Base
    def self.[](*args)
      find(*args)
    end
  end
end
