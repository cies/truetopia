class Vote
  include DataMapper::Resource

  property :step_document_id, Integer, :key => true
  property :user_id,          Integer, :key => true
  property :vector,           Enum[-1, 0, 1], :nullable => false
  property :created_at,       DateTime
  property :updated_at,       DateTime
  property :discriminator,    Discriminator  # because this model is subclassed

  belongs_to :user
  belongs_to :step_document

  def last_touched
    updated_at or created_at
  end
end
  