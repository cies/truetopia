# WARNING -- this class is not to be implemented in the first release

# might be worth making this table write only and making a 'cache' version
# that is read only that only contains the last 2 months and has indexes on
# most of its columns

class Event
  include DataMapper::Resource

  property :id,                Serial
  property :message,           String,  :nullable => false, :length => 150
  property :message_html,      String,  :length => 255
  property :created_at,        DateTime

  belongs_to :plan
  belongs_to :project
  belongs_to :documents
  belongs_to :posts
  belongs_to :users 
  belongs_to :discussions

end