module My
class Votes < Base
  def index
    @votes = Vote.all(:user_id => session.user.id)
    render
  end

  def new(vote = nil)
    if vote.nil? or vote[:vector].nil?  # initial page
      @vote = Vote.new(vote)
      render
    else  # form submitted
      @vote = Vote.new(vote)
      @vote.update_attributes(:voteable_id => voteable_id, :voteable_type => voteable_type)
      if @vote.save
        redirect url(:my_votes), :message => 'Vote has been saved'
      else
        render
      end
    end
  end
end
end  # My