class Signup < Merb::Controller
  layout :entrance
  before :ensure_unauthenticated, :exclude => %w(logout_first)  # ensure_UNautheticated (see private method below)

  def index
    redirect url(:signup, 'step1')
  end

  def step1
    render
  end

  def step2
    if user = params[:user]
      @user = User.new(user)
      if @user.save
        session.user = user
        raise "could not open a session for a user that is saved" unless session.authenticated?
        redirect url(:signup, 'completed')
      end
    else
      @user = User.new
    end
    render
  end

  def completed
    render
  end

  def logout_first
    render
  end

  def logout_to_signup
    session.abandon!
    redirect url(:signup, 'step1')
  end

  private
  def ensure_unauthenticated
    if session.authenticated?
      redirect url(:signup, 'logout_first') 
    end
  end
end
