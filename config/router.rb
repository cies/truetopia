Merb.logger.info("Compiling routes...")

# The philosophy behind this file:
#    - routes should be usable as permanent adresses to major objects on the site (projects, steps, documents, discussion posts), these addresses can then be used in wikitext [[/project/4403]]
#    - routes should be dutch on the version im working on (cies), right now they're translated right here
#    - routes should be directly usable as bread crums (needs path safety)
#    - routes should be pretty.
#    - i dont understand RESTfullness enough, nor do i see direct benefit for using it and im afraid it compromises on translatability -- so, there is no RESTfullness that im aware of..



Merb::Router.prepare do

  # this method creates routes (and their names) for a discussion.
  # names are prefixd by 'prefix' [Symbol], the prefix of the route is stored in
  # param[:context] for further use in the controller
  def discussion_on(prefix, base, parent, defaults = {})
    defaults = defaults.merge(:discussion_parent => parent, :controller => 'discussion_posts')  # dupes the defaults
    # discussion is singulare because its always only one, so no need for an :id, and never created by users direct actions
    base.match("/discussion").to(defaults).
      name("#{prefix}_discussion".to_sym)
    base.match("/discussion/posts").to(defaults.merge(:action => 'index_redirect'))  # path safety
    base.match("/discussion/posts(/:action)").to(defaults).
      name("#{prefix}_discussion_posts".to_sym)
    base.match("/discussion/post").to(defaults.merge(:action => 'index_redirect'))  # path safety
    # :code as a regexp as it has dots. and i'd rather use /(\d+\.)*\d+/, but submatch errors out
    base.match("/discussion/post/:code", :code => /[0-9\.]+/).to(defaults.merge(:action => 'show')).
      name("#{prefix}_discussion_post".to_sym)
  end

  # this method creates routes (and their names) for a document.
  # names are prefixd by 'prefix' [Symbol], the prefix of the route is stored in
  # param[:context] for further use in the controller
  def documents_for(prefix, base, parent, defaults = {})
    defaults = defaults.merge(:document_parent => parent, :controller => 'documents')  # dupes the defaults
    base.match("/documents").to(defaults.merge(:action => 'real_index'))  # actual index is more like show
    base.match("/documents(/:action)").to(defaults).# routes to index, needed otherwise the discussion is prefered
      name("#{prefix}_documents".to_sym)  # *_documents
    base.match("/document").to(defaults.merge(:action => 'real_index_redirect'))  # path safety
    base.match("/document/:document_id") do |new_base|  # add the discussion to the document
      discussion_on("#{prefix}_document".to_sym, new_base, "#{parent}Document", defaults)
    end
    base.match("/document/:document_id(/:action(/:version))").to(defaults).
      name("#{prefix}_document".to_sym)  # *_document
  end

  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # entrance controller
  match("/entrance").to(:controller => "entrance").name(:entrance)
  match("/colorpicker").to(:controller => "entrance", :action => "colorpicker").name(:colorpicker)

  # users controller -- they way to see other users (/my/* is for your own stuff)
  match("/users").to(:controller => "users", :action => 'real_index').name(:users)
  match("/user").to(:controller => "users", :action => 'real_index_redirect')  # path safety
  match("/user/:login(/:action)").to(:controller => "users").name(:user)
  match("/user/:login") { |base| documents_for(:user, base, 'User') }  # adds document routes

  # signup controller
  match("/signup(/:action)").to(:controller => "signup").name(:signup)

  # projects (are not individually owned, so do not live in /my namespace)
  match("/projects(/:action)").to(:controller => "projects").name(:projects)
  match("/project").to(:controller => "projects", :action => 'index_redirect')  # path safety
  match("/project/:project_id").to(:controller => "projects", :action => 'show')
#   match("/projects/:project_id") { |base| discussion_on :project, base, Project }  # NO PROJECT DISCUSSIONS YET
  match("/project/:project_id/step").to(:controller => "projects", :action => 'show_redirect')  # path-safety
  match("/project/:project_id/step/:step").to(:controller => "projects", :action => 'step', :document_parent => 'Step').name(:project_step)
  match("/project/:project_id/step/:step") { |base| discussion_on(:step, base, 'Step') }
  match("/project/:project_id/step/:step") { |base| documents_for(:step, base, 'Step') }  # adds document routes
  match("/project/:project_id(/:action)").to(:controller => "projects").name(:project)

  # not yet implemented
  match("/agenda").to(:controller => "priorities").name(:priorities)

#   match("/tags").to(:controller => "tags").name(:tags)
#   match("/tag/:id").to(:controller => "tags", :action => 'show').name(:tag)

  match("/search").to(:controller => "search").name(:search)


  # the /my part of the website:
  namespace :my, :path => "my" do
    %w[documents mods posts priorities profile projects searches start subscriptions votes].each do |name|
      match("/#{name}(/:action)").to(:controller => name).name(name.to_sym)
    end
    match("").to(:controller => "start", :action => 'root_redirect')  # redirects to :my_start
  end

  # no default routes as we want to be able to translate all of 'm
  # default_routes

  match('/').to(:controller => "entrance", :action => 'root_redirect').name(:root)  # redirects to :entrance
end
