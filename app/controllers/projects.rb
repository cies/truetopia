class Projects < Application
#   cache_pages :index, :show

  def index
    @projects = Project.all
#     @projects = Project.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    display @projects
  end

  def show
    @project = Project[params[:project_id]]
    display @project
  end

  def new(project_subscription = nil, step1_document = nil)
    if project_subscription  # after submitting the 1st form
      @project = Project.new(:user_id => session.user.id)
      raise "Couldn't save initial project: #{@project.errors.inspect}" unless @project.save
      @project_subscription = ProjectSubscription.new(:subscribable_id => @project.id, :user_id => session.user.id)
      @project_subscription.name = project_subscription[:name]
      if @project_subscription.save
        render :new_finished
      else
        render
      end
    else  # showing the 1st form
      @project_subscription = ProjectSubscription.new
      render
    end
  end
  
  def edit_description
    @project = Project[params[:project_id]]
    @document = @project.project_document
    if request.env['REQUEST_METHOD'] == "POST"
      @document_version = DocumentVersion.new(params[:document_version])
      @document_version.user = session.user
      @document_version.document = @document
      # saving the version update the @document.version_count
      if @document_version.save
        session[:notification] = :document_edited
        redirect url(:project, :project_id => params[:project_id])
      else
        p @document_version.errors
        display @document_version
      end
    else
      @document_version = DocumentVersion.new
      @document_version.user = session.user
      @document_version.document = @document
      @document_version.title = @document.current_version.title
      @document_version.content = @document.current_version.content
      display @document_version
    end
  end

  def history
    @project = Project[params[:project_id]]
    @document = @project.project_document
    @document_versions = @document.versions
    display @document_versions
  end

  def description_version
    @project = Project[params[:project_id]]
    @document = @project.project_document
    @document_version = @document.version(params[:version])
    session[:notification] = :not_implemented_yet if params['revert'] == 'true'
    render :description_version
  end
end
