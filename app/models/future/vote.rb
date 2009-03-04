# WARNING -- this class is not to be implemented in the first release

class Vote
  include DataMapper::Resource

  property :step_document_id, Integer, :key => true
  property :user_id,          Integer, :key => true
  property :vector,           Enum[-1, 0, 1], :nullable => false
  property :created_at,       DateTime
  property :updated_at,       DateTime
  property :discriminator,    Discriminator  # because this model is subclassed

  belongs_to :user
end

class StepDocumentVote < Vote
  belongs_to :step_document, :class_name => 'StepDocument'
  validates_present :step_document
end
  