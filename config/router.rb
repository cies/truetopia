Merb.logger.info("Compiling routes...")


# The philosophy behind this file:
#    - routes should be usable as permanent adresses to major objects on the site (projects, steps, documents, discussion posts), these addresses can then be used in wikitext [[/project/4403]]
#    - routes should be dutch on the version im working on (cies), right now they're translated right here
#    - routes should be directly usable as bread crums (needs path safety)
#    - routes should be pretty.
#    - i dont understand RESTfullness enough, nor do i see direct benefit for using it and im afraid it compromises on translatability -- so, there is no RESTfullness that im aware of..


Merb::Router.prepare do
#   # This deferred route allows permalinks to be handled, without a separate rack handler
#   defer_to do |request, path_match|
#     unless (article = Article.find_by_permalink(request.uri.to_s.chomp("/"))).nil?
#       {:controller => "documents", :action => "show", :id => article.id}
#     end
#   end


  # this method creates routes (and their names) for a discussion.
  # names are prefixd by 'prefix' [Symbol], the prefix of the route is stored in
  # param[:context] for further use in the controller
  def discussion_on(prefix, base, parent)
    prefix = prefix.to_s
    base.match("/discussion"). # discussion is singulare because its always only one
      to(:parent => parent, :controller => "discussion_posts", :action => 'index').
      name("#{prefix}_discussion".to_sym)
    base.match("/discussion/posts").to(:controller => "discussion_posts", :action => 'index_redirect')  # (path safety)
    base.match("/discussion/posts/new").
      to(:parent => parent, :controller => "discussion_posts", :action => 'new').
      name("#{prefix}_discussion_new_post".to_sym)
    base.match("/discussion/posts/:code").
      to(:parent => parent, :controller => "discussion_posts", :action => 'show').
      name("#{prefix}_discussion_post".to_sym)  # cannot catch the :code, but regexp-routes cannot be named
    base.match(%r[/discussion/([0-9\.]*)]).
      to(:parent => parent, :controller => "discussion_posts", :action => 'show', :code => '[1]')
  end

  # this method creates routes (and their names) for a document.
  # names are prefixd by 'prefix' [Symbol], the prefix of the route is stored in
  # param[:context] for further use in the controller
  def documents_for(prefix, base, parent)
    prefix = prefix.to_s
    base.match("/documents(/:document_id(/:action(/:version)))").
      to(:parent => parent,:controller => "documents").
      name("#{prefix}_document".to_sym)
    base.match("/documents/:document_id") do |base|  # add the discussion to the document
      discussion_on("#{prefix}_document".to_sym, base, Document)
    end
  end

  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # entrance controller
  match("/entrance").to(:controller => "entrance").name(:entrance)
  match("/colorpicker").to(:controller => "entrance", :action => "colorpicker").name(:colorpicker)

  # users controller -- they way to see other users (/my/* is for your own stuff)
  match("/users").to(:controller => "users").name(:users)
  match("/users/:login").to(:controller => "users", :action => 'show').name(:user)
  match("/users/:login") { |base| documents_for(:user, base, User) }  # adds document routes

  # signup controller
  match("/signup(/:action)").to(:controller => "signup").name(:signup)

  # projects (are not individually owned, so do not live in /my namespace)
  match("/projects(/:action)").to(:controller => "projects").name(:project)
  match("/projects/:project_id").to(:controller => "projects", :action => 'show').name(:project)
  match("/projects/:project_id/description(/:action(/:version))").to(:controller => "projects").name(:project_description)
  match("/projects/:project_id") { |base| discussion_on :project, base, Project }  # adds discussion routes
  match("/projects/:project_id/step").to(:controller => "projects", :action => 'show')  # path-safety, not named
  match("/projects/:project_id/step/:step").to(:controller => "projects", :action => 'step').name(:project_step)
  match("/projects/:project_id/step/:step") { |base| discussion_on(:step, base, Step) }  # adds discussion routes
  match("/projects/:project_id/step/:step") { |base| documents_for(:step, base, Step) }  # adds document routes

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
