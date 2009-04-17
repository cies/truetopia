module My
class Votes < Base
  def index
    @votes = Vote.all(:user_id => session.user.id)
    render
  end

  def new(vote = nil)
    @document = StepDocument.get()
    if vote.nil?  # initial page
      @vote = Vote.new
      render
    else  # form submitted
      @vote = Vote.new(vote)
      @vote.update_attributes(:step_document_id => step_document_id)
      if @vote.save
        redirect url(:my_votes), :message => 'Vote has been saved'
      else
        render
      end
    end
  end
end
end  # My