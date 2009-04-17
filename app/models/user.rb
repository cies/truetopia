class User
  include DataMapper::Resource

  property :id,                         Serial
  property :login,                      String, :unique_index => true, :length => 30
  property :email,                      String, :unique_index => true, :length => 255
  property :time_zone,                  String, :default => 'CET'
  property :created_at,                 DateTime
  property :updated_at,                 DateTime
  property :name,                       String, :length => 60
  property :default_formatter,          String
  # it gets                                   
  #   - :password and :password_confirmation accessors
  #   - :crypted_password and :salt db columns        
  # from the mixin.

  validates_format    :login, :with => /^[A-Za-z0-9_]+$/
  validates_length    :login, :min => 3
  validates_present   :email
  validates_format    :email, :as => :email_address
end