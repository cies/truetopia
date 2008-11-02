class Users < Application
  before :login_required

  def index
    @users = User.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    display @users
  end

  def show
    @user = User.first(:login => params[:login])
    display @user
  end

  def search
  end
end