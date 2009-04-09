module My
class Subscriptions < Base

  def index
    @subscriptions = Subscription.all(:user_id => session.user.id)
    render
  end

  def new
    if params[:subscribable_id] and params[:subscribable_type]
      # if we're making a quick subscription
      @subscription = Subscription.new({:subscribable_id => params[:subscribable_id], :subscribable_type => params[:subscribable_id], :user_id => session.user.id})
      if @subscription.save
        session[:notification] = :subscription_added
        redirect url(:my_subscriptions)
      else
        if @subscription.errors[:general].include? :subscription_allready_exists
          session[:notification] = :subscription_allready_exists
          redirect url(:my_subscriptions)
        end
      end
    else
      @subscription = Subscription.new
      display @subscription
    end
  end

end
end  # My
