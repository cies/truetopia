# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "session", :action => "create").name(:login)
        r.match("/logout").to(:controller => "session", :action => "destroy").name(:logout)
        r.resource :sessions
        r.namespace :admin do |admin|
          admin.resources :users
        end
      end
    end
  end
end