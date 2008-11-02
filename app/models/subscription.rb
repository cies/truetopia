class Subscription
  include DataMapper::Resource
  include DataMapper::Validate  # we make indirect use of it (auto validation)

  SUBSCRIBABLE_TYPES = %w{Document Project User Discussion Post AgendaItem}

  property :subscribable_id,    Integer, :key => true
  property :subscribable_type,  Integer, :key => true
  property :user_id,            Integer, :key => true
  property :created_at,         DateTime
  property :marked_read_at,     DateTime

  belongs_to :user

  validates_with_method :general, :method =>  :check_if_allready_exists

  def subscribable_obj
    Module.const_get(subscribable_type).first subscribable_id
  end

  def find_unread_events
    Events.all(:subscribable_id => self.subscribable_id, :subscribable_type => self.subscribable_type, :created_at.gt => self.marked_read_at)
  end

  def self.subscribable_types
    SUBSCRIBABLE_TYPES
  end

  private
  def check_if_allready_exists
    exists = Subscription.first(:subscribable_id => self.subscribable_id, :subscribable_type => self.subscribable_type, :user_id => self.user_id)
    return [false, :subscription_allready_exists] if exists
    return true
  end
end