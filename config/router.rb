Merb.logger.info("Compiling routes...")


# The philosophy behind this file:
#    - routes should be usable as permanent adresses to major objects on the site (projects, steps, documents, discussion posts), these addresses can then be used in wikitext [[/project/4403]]
#    - routes should be dutch on the version im working on (cies), right now they're translated right here
#    - routes should be directly usable as bread crums (needs path safety)
#    - routes should be pretty.
#    - i dont understand RESTfullness enough, nor do i see direct benefit for using it and im afraid it compromises on translatability -- so, there is no RESTfullness that im aware of..


Merb::Router.prepare do |r|
#   # This deferred route allows permalinks to be handled, without a separate rack handler
#   r.defer_to do |request, path_match|
#     unless (article = Article.find_by_permalink(request.uri.to_s.chomp("/"))).nil?
#       {:controller => "documents", :action => "show", :id => article.id}
#     end
#   end


  # this method creates routes (and their names) for a discussion.
  # names are prefixd by 'prefix' [Symbol], 'base' the reference to the parent route
  # the param[:prefix] contains the prefix.
  def discussion_on(prefix, base)
    prefix = prefix.to_s
    base.match("/discussie").
      to(:base => prefix, :controller => "discussions", :action => 'show').
      name("#{prefix}_discussion".to_sym)
    base.match("/discussie/reageer").
      to(:base => prefix, :controller => "discussions", :action => 'new_post').
      name("#{prefix}_discussion_new_root_post".to_sym)
    base.match("/discussie/reactie").
      to(:base => prefix, :controller => "discussions", :action => 'show')  # path-safety, not named
    base.match("/discussie/reactie/:parent_code/reageer").
      to(:base => prefix, :controller => "discussions", :action => 'new_post').
      name("#{prefix}_discussion_new_post".to_sym)  # cannot always catch the :code, but regexp-routes cannot be named
    base.match(%r[/discussie/reactie/([0-9\.]*)/reageer]).
      to(:base => prefix, :controller => "discussions", :action => 'new_post', :document_id => '[1]', :parent_code => '[2]')
    base.match("/discussie/reactie/:code").
      to(:base => prefix, :controller => "discussions", :action => 'view_post').
      name("#{prefix}_discussion_post".to_sym)  # cannot catch the :code, but regexp-routes cannot be named
    base.match(%r[/discussie/reactie/([0-9\.]*)]).
      to(:base => prefix, :controller => "discussions", :action => 'view_post', :document_id => '[1]', :code => '[2]')
  end

  # this method creates routes (and their names) for a document.
  # names are prefixd by 'prefix' [Symbol], 'base' the reference to the parent route
  # the param[:prefix] contains the prefix.
  def documents_for(prefix, base)
    prefix = prefix.to_s
    base.match("/documenten").
      to(:base => prefix, :controller => "documents").
      name("#{prefix}_documents".to_sym)
    base.match("/document").
      to(:base => prefix, :controller => "documents") # path-safety, not named
    base.match("/document/nieuw").
      to(:base => prefix, :controller => "documents", :action => 'new').
      name("new_#{prefix}_document".to_sym)
    base.match("/document/:id").
      to(:base => prefix, :controller => "documents", :action => 'show').
      name("#{prefix}_document".to_sym)
    base.match("/document/:id/bewerken").
      to(:base => prefix, :controller => "documents", :action => 'edit').
      name("edit_#{prefix}_document".to_sym)
    base.match("/document/:id/historie").
      to(:base => prefix, :controller => "documents", :action => 'history').
      name("#{prefix}_document_history".to_sym)
    base.match("/document/:id/versie/:version").
      to(:base => prefix, :controller => "documents", :action => 'version').
      name("#{prefix}_document_version".to_sym)
    base.match("/document/:document_id") { |base| discussion_on :document, base }  # adds discussion routes (pass on prefix?)
  end

#   # sessions controller
#   r.match("/login").to(:controller => "session", :action => "create").name(:login)
#   r.match("/loguit").to(:controller => "session", :action => "destroy").name(:logout)
#   r.match("/sessie/beeindigd").to(:controller => "session", :action => "finished").name(:session_finished)
#   r.match("/sessie/root").to(:controller => "session", :action => "root").name(:root_switch)
#   r.match("/sessie").to(:controller => "session", :action => "root")  # path-safety

  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")


  # entrance controller
  r.match("/entree").to(:controller => "entrance").name(:entrance)
  r.match("/kleurkiezer").to(:controller => "entrance", :action => "colorpicker").name(:colorpicker)


  # users controller
  r.match("/gebruikers").to(:controller => "users").name(:users)
  r.match("/gebruiker").to(:controller => "users")  # path-safety
  r.match("/gebruiker/:login").to(:controller => "users", :action => 'show').name(:user)
  r.match("/gebruiker/:login") { |base| documents_for :user, base }  # adds document routes


#   # documents controller --> DEPRICATED!!  docs should always be a part of something
#   r.match("/documenten").to(:controller => "documents").name(:documents)
#   r.match("/document").to(:controller => "documents") # path-safety, not named
#   r.match("/document/nieuw").to(:controller => "documents", :action => 'new').name(:new_document)
#   r.match("/document/:id").to(:controller => "documents", :action => 'show').name(:document)
#   r.match("/document/:id/bewerken").to(:controller => "documents", :action => 'edit').name(:edit_document)
#   r.match("/document/:id/historie").to(:controller => "documents", :action => 'history').name(:document_history)
#   r.match("/document/:id/versie/:version").to(:controller => "documents", :action => 'version').name(:document_version)
#   r.match("/document/:document_id") { |base| discussion_on :document, base }  # adds discussion routes

  # signup controller
  r.match("/aanmelden").to(:controller => "signup").name(:signup)
  r.match("/aanmelden/stap/1").to(:controller => "signup", :action => 'step1').name(:signup_step1)
  r.match("/aanmelden/stap/2").to(:controller => "signup", :action => 'step2').name(:signup_step2)
  r.match("/aanmelden/voltooid").to(:controller => "signup", :action => 'completed').name(:signup_completed)
  r.match("/aanmelden/eerst_uitloggen").to(:controller => "signup", :action => 'logout_first').name(:logout_first)
  r.match("/aanmelden/uitloggen_en_aanmelden").to(:controller => "signup", :action => 'logout_to_signup').name(:logout_to_signup)


  # projects
  r.match("/projecten").to(:controller => "projects").name(:projects)
  r.match("/project").to(:controller => "projects")  # path-safety, not named
  r.match("/project/nieuw").to(:controller => "projects", :action => 'new').name(:new_project)
  r.match("/project/:project_id").to(:controller => "projects", :action => 'show').name(:project)
  r.match("/project/:project_id/beschrijving/bewerken").to(:controller => "projects", :action => 'edit_description').name(:edit_project_description)
  r.match("/project/:project_id/historie").to(:controller => "projects", :action => 'history').name(:project_history)
  r.match("/project/:project_id/beschrijving/versie/:version").to(:controller => "projects", :action => 'description_version').name(:project_description_version)
  r.match("/project/:project_id") { |base| discussion_on :project, base }  # adds discussion routes

  r.match("/project/:project_id/stap").to(:controller => "projects", :action => 'show')  # path-safety, not named
  r.match("/project/:project_id/stap/:step").to(:controller => "projects", :action => 'step').name(:project_step)
  r.match("/project/:project_id/stap/:step") { |base| discussion_on :step, base }  # adds discussion routes
  r.match("/project/:project_id/stap/:step") { |base| documents_for :step, base }  # adds document routes

  # not yet implemented

  r.match("/tags").to(:controller => "tags").name(:tags)
  r.match("/tag/:id").to(:controller => "tags", :action => 'show').name(:tag)


  # the /my part of the website:
  r.namespace :my, :path => "mijn" do |my|
    my.match("/start").to(:controller => "start").name(:start)

    my.match("/profiel").to(:controller => "profile").name(:profile)

    my.match("/mods").to(:controller => "mods").name(:mods)
    my.match("/mods/nieuw").to(:controller => "mods", :action => 'new').name(:new_mod)

    my.match("/stemmen").to(:controller => "votes").name(:votes)
    my.match("/stem/nieuw").to(:controller => "votes", :action => 'new').name(:new_vote)

    my.match("/oogjes").to(:controller => "subscriptions").name(:subscriptions)
    my.match("/oogjes/nieuw").to(:controller => "subscriptions", :action => 'new').name(:new_subscription)
    # -- the rest by ?qwe=2&b=12 params..

    my.match("/projecten").to(:controller => "projects").name(:projects)

    my.match("/documenten").to(:controller => "documents").name(:documents)

    my.match("/reacties").to(:controller => "posts").name(:posts)

    my.match("/zoekopdrachten").to(:controller => "searches").name(:searches)

    my.match("").to(:controller => "start", :action => 'root_redirect') # redirects to :my_start
  end





  r.match("/zoeken").to(:controller => "search").name(:search)


  # no default routes as we want to translate all of 'm
  # r.default_routes
  r.match('/').to(:controller => "entrance", :action => 'root_redirect').name(:root) # redirects to :entrance
end

# not translatable this way
# AuthenticatedSystem.add_routes
