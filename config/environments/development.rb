Merb.logger.info("Loaded DEVELOPMENT Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = true
  c[:reload_time] = 0.5
}

Merb::BootLoader.after_app_loads do
  begin
    if User.all.empty?
      u = User.new(:login => 'cies', :password => 'cies', :password_confirmation => 'cies', :email => 'c@k.nl')
      if u.save
        Merb.logger.info("A user called 'cies' was created for developement purpose...")
      else
        Merb.logger.info("Couldn't create a user for developement purpose...")
      end
    end
  rescue
    Merb.logger.info("Couldn't create a user for developement purpose, possibly unable to access the database.")
  end
end