# WARNING -- this class is not to be implemented in the first release

class Subscription
  include DataMapper::Resource

  property :subscribable_id,    Integer,       :key => true
  property :discriminator,      Discriminator, :key => true
  property :user_id,            Integer,       :key => true
  property :created_at,         DateTime
  property :marked_read_at,     DateTime

  belongs_to :user

  def find_unread_events
    Events.all("#{subscribable_type}_id".to_sym => subscribable_id, :created_at.gt => marked_read_at)
  end

  private
  def subscribable_type
    discriminator[0..-13].snake_case
  end
end

class DocumentSubscription; end
class ProjectSubscription; end
class UserSubscription; end
class DiscussionSubscription; end
class PostSubscription; end
class PlanSubscription; end
