class Entrance < Merb::Controller
  layout :entrance

  def index
    render
  end

  # we have to put it somewhere, for now it fits best here at the entrance ;)
  def colorpicker
    if params['color']
      cookies['color'] = "##{params['color']}"
      redirect '/'
    end
    render
  end

  def root_redirect
    # '/' requests are routed to this action, that only redirects
    redirect url(:entrance)
  end
end
