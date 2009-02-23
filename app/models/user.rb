class User
  include DataMapper::Resource

  attr_accessor :password, :password_confirmation

  property :id,                         Integer, :key => true, :serial => true
  property :login,                      String, :length => 30
  property :email,                      String, :length => 255
  property :time_zone,                  String, :default => 'CET'
  property :created_at,                 DateTime
  property :updated_at,                 DateTime
  property :name,                       String, :length => 60
  property :default_formatter,          String
  # it gets                                   
  #   - :password and :password_confirmation accessors
  #   - :crypted_password and :salt db columns        
  # from the mixin.

  validates_format :login, :with => /^[A-Za-z0-9_]+$/
  validates_length :login, :min => 3
  validates_is_unique :login
  validates_length            :login,                   :within => 3..30
  validates_is_unique         :login
  validates_present           :password
  validates_present           :password_confirmation
  validates_length            :password,                :within => 4..40
  validates_is_confirmed      :password,                :groups => :create
  validates_present           :email

  before :save do
    encrypt_password
  end

  after :save do
    set_create_event
    set_update_event
  end

  def set_create_event
    Event.register(self, :user_created) unless new_record?
  end

  def set_update_event
    Event.register(self, :user_updated) unless new_record?
  end

  def login=(value);
    attribute_set :login, value.downcase unless value.nil?
  end
end