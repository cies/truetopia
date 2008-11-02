
class Session < Application
  skip_before :login_required

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      unless params[:login].nil? and params[:password].nil?
        session[:notification] = :couldnt_log_in if params[:login] and params[:password]
        session[:notification] = :no_password if params[:password].empty?
        session[:notification] = :no_login    if params[:login].empty?
        # put login in the session a redirect is possible
        session[:remembered_login] = params[:login] if params[:login]
      end
      # this hides this controller from the url when logging in
      if request.uri == url(:login)
        render :new
      else
        redirect url(:login)
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect url(:session_finished)
  end

  def finished
    render
  end
end
