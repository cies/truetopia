class Vote
  include DataMapper::Resource
  include DataMapper::Validate  # we make indirect use of it (auto validation)

  VOTEABLE_TYPES = %w{ProjectDocument AgendaItem}
  VECTORS = [-1, 0, 1]

  property :voteable_id,    Integer, :key => true
  property :voteable_type,  Integer, :key => true
  property :user_id,        Integer, :key => true
  property :vector,         Integer, :nullable => false
  property :created_at,     DateTime
  property :updated_at,     DateTime
  property :discriminator,  Discriminator  # because this model is subclassed

  belongs_to :user

  before :save do
    :check_vector
  end


  def self.highest_vote_activity_last(time)
   # ... difficult, maybe put it in a SQL query
  end

  def self.count_and_average_for(obj)
    raise 'Only works for voteable types' unless Vote.voteable_types.includes? obj.class.to_s
    count = Vote.count(:voteable_id => obj.id, :voteable_type => obj.class.to_s)
    avg   = Vote.avg(:vector, :voteable_id => obj.id, :voteable_type => obj.class.to_s)
    [count, avg]
  end

  def self.voteable_types
    VOTEABLE_TYPES
  end

  private
  def check_vector
    raise 'Illegal vote vector' unless VECTORS.includes? self.vector
  end
end


class AgendaVote < Vote
  property :agend_item_id, Integer, :nullable => false

  belongs_to :agenda_item
end


class ProjectDocumentVote < Vote
  property :document_id, Integer, :nullable => false

  belongs_to :document, :class_name => 'ProjectDocument'
end