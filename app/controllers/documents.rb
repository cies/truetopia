class Documents < Application
#   cache_pages :index, :show

  def real_index
    get_context
    @documents = case params[:document_parent]
      when 'Step'
        StepDocument.all(:project_id => @project.id, :discriminator => "Step#{params[:step]}Document")
      when 'User'
        UserDocument.all(:user_id => @user.id, :discriminator => "UserDocument")
      else
        raise "Unknown parent for document: #{params[:document_parent].inspect}"
    end
    render :index
  end

  def real_index_redirect  # actually more like show
    redirect document_url
  end

  def index  # actually more like show
    get_context
    @document = Document.get(params[:document_id])
    render :show
  end

  def new(document_version = nil)
    get_context
    if document_version  # when the form has been submitted
      # create the document first
      @document = case params[:document_parent]
        when 'Step'
          StepDocument.new(:user => session.user, :project => @project, :discriminator => "Step#{params[:step]}Document")
        when 'User'
          UserDocument.new(:user => session.user, :user => @user, :discriminator => "UserDocument")
        else
          raise "Unknown parent for document: #{params[:document_parent].inspect}"
      end
      raise "Couldn't save initial document: #{@document.errors}" unless @document.save

      @document_version = DocumentVersion.new(document_version)
      @document_version.user = session.user
      @document_version.document = @document
      if @document_version.save
        to_url = url(:step_document, params[:project_id], params[:step], @document.id)
        redirect to_url, :message => "Changes have been saved as version #{@document_version.number}"
      else
        @document.destroy  # i see no other way than to destroy @document here (only with initial versions)
        render
      end
    else  # initial call
      @document_version = DocumentVersion.new
      render
    end
  end
  
  def edit(document_id, document_version = nil)
    get_context
    @document = Document.get(document_id) or raise NotFound
    if document_version  # form submitted
      @document_version = DocumentVersion.new(document_version)
      @document_version.user = session.user
      @document_version.document = @document
      # saving the version update the @document.version_count
      if @document_version.save
        redirect document_url(:document_id => @document.id), :message => 'Document edited'
      else
        render
      end
    else  # initial page
      @document_version = DocumentVersion.new
      @document_version.title = @document.current_version.title
      @document_version.content = @document.current_version.content
      render
    end
  end

  def history(document_id)
    get_context
    @document = Document.get(document_id) or raise NotFound
    if params[:from] and params[:to]
      @from_version = @document.version(params[:from]) or raise NotFound
      @to_version   = @document.version(params[:to])   or raise NotFound
      @diff = @document.diff(@from_version, @to_version, :content)
      render :history_diff
    else
      @document_versions = @document.versions
      render
    end
  end

  def version
    get_context
    @document_version = DocumentVersion.first(:document_id => params[:document_id], :number => params[:version])
    @document = @document_version.document
    session[:notification] = :not_implemented_yet if params['revert'] == 'true'
    render :show_version
  end

  private
  def get_context
    case params[:document_parent]
      when 'Step'
        @project = Project.get(params[:project_id]) or raise NotFound
        @step = @project.step(params[:step]) or raise NotFound
      when 'User'
        @project = Project.get(params[:project_id]) or raise NotFound
        @step = @project.step(params[:step]) or raise NotFound
      else
        raise "No context to be loaded for #{params[:parent]}"
    end
  end
end
