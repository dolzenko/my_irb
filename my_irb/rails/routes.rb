module MyIrb::Rails
  module Routes
    # Convenience method for testing routes as suggested at "Agile Web Development with Rails", Playing with Routes section
    # >> puts rs.routes
    # >> rs.recognize_path "/store"
    # >> rs.generate :controller => :store
    # to reload:
    # >> load "config/routes.rb"
    def rs
      ActionController::Routing::Routes
    end

    def include_routes
      if Rails::VERSION::MAJOR == 2
        include ActionController::UrlWriter
        self.default_url_options = { :host => SELFPORT }
      elsif Rails::VERSION::MAJOR == 3
        include Rails.application.routes.url_helpers
      end
      "Named routes included"
    end

    def rebuilding_routes
      if rebuilding_routes?
        @@route_rebuilding_thread.kill
        @@route_rebuilding_thread = nil
      else
        @@route_rebuilding_thread = Thread.new { MyIrb::Rails::RoutesBuilding.build }
      end

      MyIrb.context.main.class_eval do

        def reload_with_rebuilding!
          had_routes_rebuildind = true if MyIrb::Rails::Routes.rebuilding_routes?
          rebuilding_routes if had_routes_rebuildind # effectively kills the thread

          reload_without_rebuilding!

          rebuilding_routes if had_routes_rebuildind # starts it again
        end

        alias_method_chain :reload!, :rebuilding

      end unless MyIrb.context.main.respond_to?(:reload_with_rebuilding!)

      rebuilding_routes?
    end

    module_function
    
    def rebuilding_routes?
      !!(defined?(@@route_rebuilding_thread) && @@route_rebuilding_thread)
    end
  end
end