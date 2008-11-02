class Signup < Application
  before :login_check, :only => %w(step1 step2)

  def index
    redirect url(:signup_step1)
  end

  def step1
    render
  end

  def step2
    if request.env['REQUEST_METHOD'] == "POST"
      cookies.delete :auth_token
      @user = User.new(params[:user])
      if @user.save
        self.current_user = User.authenticate(params[:user][:login], params[:user][:password])
        raise "could not open a session for a user that is saved" unless logged_in?
        redirect url(:signup_completed)
      end
    else
      @user = User.new
    end
    display @user
  end

  def completed
    render
  end

  def logout_first
    render
  end

  def logout_to_signup
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect url(:signup_step1)
  end

  private
  def login_check
    if logged_in?
      redirect url(:logout_first) 
    end
  end
end
