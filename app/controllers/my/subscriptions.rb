module My
class Subscriptions < Base

  def index
    @subscriptions = Subscription.all(:user_id => session.user.id)
    render
  end

  def dialog
    only_provides :js
    # since we can get *_subscription as key in the params we first pick the right param:
    subscription = params.collect{ |k,v| k =~ /subscription/i ? v : nil }.compact.first
    if subscription  # after submitting the selection form (or coming in by ajax call)
      klass = nil
      begin
        klass = Kernel.const_get subscription[:discriminator]
      rescue NameError
        raise NotFound  # if no valid discriminator is specified
      end
      if @subscription = klass.get(subscription[:subscribable_id], subscription[:discriminator], session.user.id)
        
      else @subscription = klass.new(subscription.merge(:user_id => session.user.id))
        if @subscription.save
          render :new_finished
        else
          render :confirm_new
        end
      end
    else
      raise NotFound
    end
  end

#   def new
#     provides :js  # this method gets ajax calls
# #     if params[:id] and params[:type]
#     subscription = params.collect{ |k,v| k =~ /subscription/i ? v : nil }.compact.first
#     if subscription  # after submitting the selection form (or coming in by ajax call)
#       klass = nil
#       begin
#         klass = Kernel.const_get subscription[:discriminator]
#       rescue NameError
#         raise NotFound  # if no valid discriminator is specified
#       end
#       @subscription = klass.new(subscription.merge(:user_id => session.user.id))
#       if @subscription.save
#         render :new_finished
#       else
#         render :confirm_new
#       end
#     else  # showing the selection form -- TODO should be something like a search
#       render
#     end
#   end

end
end  # My
