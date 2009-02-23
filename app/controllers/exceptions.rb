class Exceptions < Merb::Controller
  layout :entrance

  # handle internal server errors (50x)
  def internal_server_error
    render :format => :html
  end
  
  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

  # handle Unauthenticated
  def unauthenticated
    render :format => :html
  end

  # handle Under privileged
  def underprivileged
    render :format => :html
  end
end

class Underprivileged <  Merb::ControllerExceptions::Unauthorized; end