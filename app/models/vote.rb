class Vote
  include DataMapper::Resource

  property :user_id,          Integer, :key => true
  property :document_id,      Integer, :key => true
  property :version,          Integer, :nullable => true  # nil means 'latest version'
  property :vector,           Enum[-1, 0, 1], :nullable => false
  property :created_at,       DateTime
  property :updated_at,       DateTime

  belongs_to :user
  belongs_to :step_document

  def last_touched_at
    updated_at or created_at
  end
end
  