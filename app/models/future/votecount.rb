# WARNING -- this class is not to be implemented in the first release

class VoteCount
  include DataMapper::Resource
  before :create do
    set_vote_balance
    set_platform
  end

  property :voteable_id,    Integer,  :key => true
  property :voteable_type,  String,   :key => true
  property :created_at,     DateTime, :key => true
  property :vote_balance,   Integer,  :nullable => false
  property :platform,       Float,    :nullable => false
  
  def last_count
    get_last_count
    @last_count
  end

private
  def set_vote_balance
    vote_balance = Votes.sum(:vector, :voteable_id => voteable_id, :voteable_type => voteable_type)
  end
  
  def set_platform
    if last_count == 0 or last_count.vote_balance.sign != vote_balance.sign
      platform = vote_balance
    else
      platform = vote_balance + last_count.platform
    end
  end

  def get_last_count
    # make sure this gets only pulled once from the db
    return @last_count if @last_count
    @last_count = VoteCount.first(:voteable_id => voteable_id, :voteable_type => voteable_type, :order => [:created_at.desc])
    return 0 unless @last_count
    return @last_count
  end
end