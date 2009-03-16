class Subscription
  include DataMapper::Resource

  property :subscribable_id,    Integer,       :key => true
  property :discriminator,      Discriminator, :key => true
  property :user_id,            Integer,       :key => true
  property :created_at,         DateTime
  property :marked_read_at,     DateTime,      :default => DateTime.now

  belongs_to :user

  def find_unread_events
    Events.all("#{subscribable_type}_id".to_sym => subscribable_id, :created_at.gt => marked_read_at)
  end

  private
  def subscribable_type
    discriminator[0..-13].snake_case
  end
end


class ProjectSubscription < Subscription
  property :name, String
  validates_present :name
end
class DocumentSubscription < Subscription; end
class UserSubscription < Subscription; end
class DiscussionSubscription < Subscription; end
class PostSubscription < Subscription; end
class PlanSubscription < Subscription; end
