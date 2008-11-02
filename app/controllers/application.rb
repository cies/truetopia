class Application < Merb::Controller
  include Merb::AssetsMixin

  layout :application

  before :fix_cache_issue_with_merb_093
  
  ##
  # This just makes sure that params[:format] isn't null, to get around the merb 0.9.3 cache issue
  def fix_cache_issue_with_merb_093
    params[:format] = [] if params[:format].nil?
  end

  ##
  # This puts notification text in the session, to be rendered in any view
  def notify(text)
    session[:notifications] = text
  end
end