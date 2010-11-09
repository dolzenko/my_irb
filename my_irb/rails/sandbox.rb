module MyIrb::Rails
  module Sandbox
    def sandbox

# go into sandbox
ActiveRecord::Base.connection.increment_open_transactions
ActiveRecord::Base.connection.begin_db_transaction
at_exit do
  ActiveRecord::Base.connection.rollback_db_transaction
  ActiveRecord::Base.connection.decrement_open_transactions
end
puts 'Environment sandboxed, all changes will be rolled back on exit'
nil

end
end
end