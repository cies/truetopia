
# Discussions are created by Documents
# 1-1 with documents and projects

class Discussion
  include DataMapper::Resource
  include DataMapper::Validate

  property :id,               Integer, :key => true, :serial => true     # used by Post and Subscription
  property :created_at,       DateTime
  property :discriminator,    Discriminator  # because this model is subclassed

  # belongs_to discussables through a polymorphic, non-datamapper, relation
  has n, :posts

  def post_count
    Post.count(:discussion_id => self.id)
  end

  def post_from_last_week
    Post.count(:discussion_id => self.id, :created_at.gt => Time.now - 7.days)
  end

  def root_posts
    Post.all(:discussion_id => self.id, :parent_code => nil)
  end

  def root_post_count
    Post.count(:discussion_id => self.id, :parent_code => nil)
  end
end

class DocumentDiscussion < Discussion
  property :document_id, Integer  # cannot set :nullable => false, so using a validation

  validates_present :document_id

  belongs_to :document
end

class StepDiscussion < Discussion
  property :project_id, Integer  # cannot set :nullable => false, so using a validation
  property :number,     Integer, :length => 10  # cannot set :nullable => false, so using a validation

  validates_present :project_id, :step

  def step
    Step.first(:project_id => project_id, :number => number)
  end
end