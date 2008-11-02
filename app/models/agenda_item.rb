class AgendaItem
  include DataMapper::Validate
  include DataMapper::Resource

  property :id,                Integer, :key => true,   :serial => true
  property :number,            Integer  # starts as nil
  property :created_at,        DateTime
  property :project_id,        Integer, :nullable => false
  property :doc1_id,           Integer, :nullable => false
  property :doc1_version,      Integer, :nullable => false
  property :doc2_id,           Integer, :nullable => false
  property :doc2_version,      Integer, :nullable => false
  property :doc3_id,           Integer, :nullable => false
  property :doc3_version,      Integer, :nullable => false

  belongs_to :project

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