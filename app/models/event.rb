class Event
  include DataMapper::Validate
  include DataMapper::Resource

  property :id,                Integer, :key => true,   :serial => true
  property :subscribable_id,   Integer, :nullable => false
  property :subscribable_type, String,  :nullable => false, :length => 20
  property :message,           String,  :nullable => false, :length => 150
  property :message_html,      String,  :length => 255
  property :created_at,        DateTime


  def self.register(obj, msg_sym, user = nil)
    type = obj.class.to_s
    raise "Could not create an event for #{type}" unless subscribable_types.include? type
    msg = Translator.translate_event_message(obj, msg_sym)  # translate the message symbol
    Event.create(:subscribable_id => obj.id, :subscribable_type => type, :message => msg)
  end

  def self.subscribable_types
    Subscription.subscribable_types
  end
end