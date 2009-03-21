class Discussion
  include DataMapper::Resource

  property :id,               Serial  # used by Post and Subscription
  property :created_at,       DateTime
  property :discriminator,    Discriminator

  has n, :posts

#   def post_count
#     Post.count(:discussion_id => self.id)
#   end
#   def post_from_last_week
#     Post.count(:discussion_id => self.id, :created_at.gt => Time.now - 7.days)
#   end

  def posts_hash  # one approch to pulling a discussion in with one query (UNSUSED SO FAR)
    result = {}
    posts.each { |x| result[x.code] = x }
    result
  end

  def root_posts
    Post.all(:discussion_id => self.id, :parent_code => nil)
  end

  def root_post_count
    Post.count(:discussion_id => self.id, :parent_code => nil)
  end
end

class DocumentDiscussion < Discussion
  belongs_to :document
  validates_present :document
end

class StepDiscussion < Discussion
  property :step, Integer
  belongs_to :project
  validates_present :project, :step
end

## no project discussion for now, use step discussions to have your say
# class ProjectDiscussion < Discussion
#   belongs_to :project
#   validates_present :project
# end
# class StepDiscussion < ProjectDiscussion
#   property :step, Integer
#   validates_present :step
#   
# end
