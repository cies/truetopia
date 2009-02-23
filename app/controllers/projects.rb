class Projects < Application
#   cache_pages :index, :show

  def index
    @projects = Project.all(:order => [:updated_at.desc])
#     @projects = Project.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    display @projects
  end

  def show
    @project = Project[params[:project_id]]
    display @project
  end

  def new
    if request.env['REQUEST_METHOD'] == "POST"
      # create the project and project document first
      @project = Project.new(:user_id => session.user.id)
      raise "Couldn't save initial project: #{@project.errors.inspect}" unless @project.save
      @document = ProjectDocument.new(:user_id => session.user.id, :project_id => @project.id)
      raise "Couldn't save initial document: #{@document.errors.inspect}" unless @document.save

      @document_version = DocumentVersion.new(params[:document_version])
      @document_version.user = session.user
      @document_version.document = @document
      @document_version.comment = '-----'
      if @document_version.save
        redirect url(:project, :project_id => params[:project_id])
      else
        @project.destroy
        @document.destroy
        render :new
      end
    else
      @document_version = DocumentVersion.new
      display @document_version
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
