class Users < Application
  def real_index
    @users = User.all #.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    render :index
  end

  def index  # actually more like show
    @user = User.first(:login => params[:login])
    render :show
  end

  def search
  end
end
