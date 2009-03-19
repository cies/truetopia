class Documents < Application
#   cache_pages :index, :show

  def real_index
    @documents = Document.all #.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    render :index
  end

  def index  # actually more like show
    @document = Document.get(params[:document_id])
    render :show
  end

  def new(document_version = nil)
    if document_version  # when the form has been submitted
      # create the document first
      @document = case params[:parent].to_s
        when 'Step'
          Document.new(:user_id => session.user.id, :discriminator => "Step#{params[:step]}Document")
        else
          raise "Unknown parent for document: #{params[:parent].inspect}"
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
    @document = Document.get(document_id) or raise NotFound
    if document_version  # form submitted
      @document_version = DocumentVersion.new(document_version)
      @document_version.user = session.user
      @document_version.document = @document
      # saving the version update the @document.version_count
      if @document_version.save
        redirect document_url, :message => 'Document edited'
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
    @document = Document.get(document_id) or raise NotFound
    @document_versions = @document.versions
    render
  end

  def version
    @document_version = DocumentVersion.first(:document_id => params[:document_id], :number => params[:version])
    @document = @document_version.document
    session[:notification] = :not_implemented_yet if params['revert'] == 'true'
    render :show_version
  end
end
