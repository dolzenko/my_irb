module MyIrb::Rails
  module LogToConsole
    def log_to_console
      if @@is_on = !(defined?(@@is_on) && @@is_on)
        ActionController::Base.logger, @@prev_action_controller_base_logger =
                ActiveSupport::BufferedLogger.new(STDOUT), ActionController::Base.logger

        ActiveRecord::Base.logger, @@prev_active_record_base_logger =
                ActiveSupport::BufferedLogger.new(STDOUT), ActiveRecord::Base.logger

        reload!
      else
        ActionController::Base.logger = @@prev_action_controller_base_logger
        ActiveRecord::Base.logger = @@prev_active_record_base_logger

        reload!
      end
      
      @@is_on
    end
  end
end