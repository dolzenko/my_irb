module MyIrb::Rails
  module LogToConsole
    def log_to_console
      if @@is_on = !(defined?(@@is_on) && @@is_on)
        ActionController::Base.logger, @@prev_action_controller_base_logger =
                ActiveSupport::BufferedLogger.new(STDOUT), ActionController::Base.logger rescue nil

        ActiveRecord::Base.logger, @@prev_active_record_base_logger =
                ActiveSupport::BufferedLogger.new(STDOUT), ActiveRecord::Base.logger if ActiveRecord::Base.respond_to?(:logger=)

        Mongoid::Config.instance.logger, @@prev_mongoid_logger = Logger.new($stdout, :warn), Mongoid::Config.instance.logger
        
        reload!
      else
        ActionController::Base.logger = @@prev_action_controller_base_logger rescue nil
        ActiveRecord::Base.logger = @@prev_active_record_base_logger if ActiveRecord::Base.respond_to?(:logger=)
        Mongoid::Config.instance.logger = @@prev_mongoid_logger rescue nil

        reload!
      end
      
      @@is_on
    end
  end
end