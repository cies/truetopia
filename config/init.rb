# Go to http://wiki.merbivore.com/pages/init-rb
 
# Specify a specific version of a dependency
# dependency "RedCloth", "> 3.0"

gem "archive-tar-minitar"
dependency "merb-helpers"
dependency "merb-assets"
dependency "merb-cache"
# dependency "merb-action-args"
dependency "merb-mailer"
#dependency "merb_paginate"
dependency "dm-core"
dependency "dm-aggregates"
# dependency "dm-is-tree"
dependency "dm-validations"
dependency "dm-timestamps"
# dependency "merb-haml"

use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:session_secret_key] = '628e7fc28c143e4745043f19f31cc14979a83193'  # required for cookie session store
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  c[:use_mutex] = false
  c[:use_mutex] = false
  c[:session_store] = 'cookie'
  
  # cookie session store configuration
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end


# # # Make the app's "gems" directory a place where gems are loaded from
# # Gem.clear_paths
# # Gem.path.unshift(Merb.root / "gems")
# # 
# # # Make the app's "lib" directory a place where ruby files get "require"d from
# # $LOAD_PATH.unshift(Merb.root / "lib")
# # 
# # Merb::Config.use do |c|
# #   ### Sets up a custom session id key, if you want to piggyback sessions of other applications
# #   ### with the cookie session store. If not specified, defaults to '_session_id'.
# #   # c[:session_id_key] = '_session_id'
# #   c[:session_secret_key] = '95bf50e5bb36b2a455611792c271f2581e6b21db'
# #   c[:session_store] = 'cookie'
# #   c[:use_mutex] = false
# # end
# # 
# # 
# # ### DataMapper!
# # use_orm :datamapper
# # 
# # ### This defines which test framework the generators will use
# # ### rspec is turned on by default
# # ###
# # ### Note that you need to install the merb_rspec if you want to ue
# # ### rspec and merb_test_unit if you want to use test_unit. 
# # ### merb_rspec is installed by default if you did gem install
# # ### merb.
# # ###
# # # use_test :test_unit
# # use_test :rspec, "merb_stories"
# # 
# # 
# # ### Add your other dependencies here
# # gem "archive-tar-minitar"
# # dependency "merb_helpers"
# # dependency "merb-assets"
# # dependency "merb-cache"
# # # dependency "merb-action-args"
# # dependency "merb-mailer"
# # dependency "merb_paginate"
# # dependency "datamapper"
# # dependency "dm-aggregates"
# # dependency "dm-is-tree"
# # dependency "dm-validations"
# # dependency "dm-timestamps"
# # dependency "merb-haml"
# # 
# # # an example of version specific dependency:
# # # dependencies "RedCloth" => "> 3.0", "ruby-aes-cext" => "= 1.0"
# # 
# # Merb::BootLoader.after_app_loads do
# #   require "tzinfo"
# #   require "net/http"
# #   require "uri"
# #   require "cgi"
# #   require "erb"
# #   require "zlib"
# #   require "stringio"
# #   require "archive/tar/minitar"
# # 
# #   Merb::Mailer.delivery_method = :sendmail
# # end
# # 
# # begin 
# #   require File.join(File.dirname(__FILE__), '..', 'lib', 'authenticated_system/authenticated_dependencies') 
# # rescue LoadError
# # end
# # 
# # Merb::Plugins.config[:merb_cache] = {
# #    :cache_html_directory => Merb.dir_for(:public)  / "cache",
# #    :store => "file",
# #    :cache_directory => Merb.root_path("tmp/cache")
# # }
