module MyIrb::Rails
  module SwitchDbs
    ::ActiveRecord::Base.configurations.keys.each do |env|
      # Generates methods like
      #
      #     use_production_db
      #     use_development_db
      #     ....
      #
      # to quickly switch between databases

      define_method("use_#{ env }_db") do
        ActiveRecord::Base.establish_connection env
        "Start using #{ env } environment database: #{ ::ActiveRecord::Base::configurations[env]["database"] }"
      end
    end if ::ActiveRecord::Base.respond_to?(:configurations)
  end
end