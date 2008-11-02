class Exceptions < Application
  layout :entrance

  # only declare the actions if we need pretty error pages (PRODUCTION)
  # otherwise (DEVELOPMENT) the default merb stacktrace page does well
  unless ::Merb::Config[:exception_details]

    # handle internal server errors
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
  end
end