module My
  class Start < Base

    def index
      render
    end

    def root_redirect
     # '/my' root requests are routed to this action, that only redirects
      redirect url(:my_start)
    end
  end
end