class Documents < Application
  before :login_required
#   cache_pages :index, :show

  def index
    @documents = Document.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    display @documents
  end

  def show
    @document = Document[params[:id]]
    display @document
  end

  def new
    if request.env['REQUEST_METHOD'] == "POST"
      # create the document first
      @document = Document.new(:user_id => current_user.id)
      raise "Couldn't save initial document: #{@document.errors}" unless @document.save

      @document_version = DocumentVersion.new(params[:document_version])
      @document_version.user = current_user
      @document_version.document = @document
      @document_version.comment = '-----'
      if @document_version.save
        redirect url(:document, :id => params[:id])
      else
        @document.destroy
        render :new
      end
    else
      @document_version = DocumentVersion.new
      display @document_version
    end
  end
  
  def edit
    @document = Document[params[:id]]
    if request.env['REQUEST_METHOD'] == "POST"
      @document_version = DocumentVersion.new(params[:document_version])
      @document_version.user = current_user
      @document_version.document = @document
      # saving the version update the @document.version_count
      if @document_version.save
        session[:notification] = :document_edited
        redirect url(:document, :id => params[:id])
      else
        p @document_version.errors
        display @document_version
      end
    else
      @document_version = DocumentVersion.new
      @document_version.user = current_user
      @document_version.document = @document
      @document_version.title = @document.current_version.title
      @document_version.content = @document.current_version.content
      display @document_version
    end
  end

  def history
    @document = Document[params[:id]]
    @document_versions = @document.versions
    display @document_versions
  end

  def version
    @document = Document[params[:id]]
    @document_version = DocumentVersion.first(:document_id => params[:id], :number => params[:version])
    session[:notification] = :not_implemented_yet if params['revert'] == 'true'
    render :show_version
  end
end