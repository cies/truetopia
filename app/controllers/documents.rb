class Documents < Application
#   cache_pages :index, :show

  def real_index
    get_context
    @documents = case params[:document_parent]
      when 'Step'
        StepDocument.all(:discriminator => "StepDocument", :project_id => @project.id, :step_number => params[:step])
      when 'User'
        UserDocument.all(:discriminator => "UserDocument", :user_id => @user.id)
      else
        raise "Unknown parent for document: #{params[:document_parent].inspect}"
    end
    render :index
  end

  def real_index_redirect  # actually more like show
    redirect document_url
  end

  def index(number, version = nil)  # actually more like show
    get_context; get_document
    if version
      @document.current_version_number = version
      render :show
    else
      redirect document_url(:number => number, :version => @document.versions.count),
        :message => "You have been redireted to the latest version of document ##{number}"
    end
  end

  def new(document_version = nil)
    get_context
    if document_version  # when the form has been submitted
      # create the document first
      @document = case params[:document_parent]
        when 'Step'
          StepDocument.new(:user => session.user, :project => @project, :step => @project.step(params[:step]))
        when 'User'
          UserDocument.new(:user => session.user)
        else
          raise "Unknown parent for document: #{params[:document_parent].inspect}"
      end
      raise "Couldn't save initial document: #{@document.errors}" unless @document.save

      @document_version = DocumentVersion.new(document_version)
      @document_version.user = session.user
      @document_version.document = @document
      if @document_version.save
        @document.current_version_number = @document_version.number 
        redirect document_url(@document), :message => "Changes have been saved as version #{@document_version.number}"
      else
        @document.destroy  # i see no other way than to destroy @document here (only with initial versions)
        render
      end
    else  # initial call
      @document_version = DocumentVersion.new
      render
    end
  end
  
  def edit(document_version = nil)
    get_context; get_document
    @document.current_version_number = params[:version]
    if document_version  # form submitted
      @document_version = DocumentVersion.new(document_version)
      @document_version.user = session.user
      @document_version.document = @document
      if @document_version.save
        @document.current_version_number = @document_version.number 
        redirect document_url(@document), :message => 'Document edited'
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

  def history
    get_context; get_document
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

#   def version
#     get_context
#     @document_version = DocumentVersion.first(:document_id => params[:document_id], :number => params[:version])
#     @document = @document_version.document
#     session[:notification] = :not_implemented_yet if params['revert'] == 'true'
#     render :show_version
#   end

  private
  def get_context
    case params[:document_parent]
      when 'Step'
        @project = Project.get(params[:project_id]) or raise NotFound
        @step = @project.step(params[:step]) or raise NotFound
      when 'User'
        @user = User.first(:login => params[:login]) or raise NotFound
      else
        raise "No context to be loaded for #{params[:document_parent]}"
    end
  end

  def get_document
    @document = case params[:document_parent]
      when 'Step'
        StepDocument.first(:project_id => @project.id, :step_number => params[:step],
          :step_document_number => params[:number]) or raise NotFound
      when 'User'
        UserDocument.first(:user_id => @user.login, :user_document_number => params[:number]) or raise NotFound
      else
        raise "No document to be loaded for #{params[:document_parent]}"
    end
  end
end
