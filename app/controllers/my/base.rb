module My
  class Base < Application
    # layout :my
    before :login_required
  end
end