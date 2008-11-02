require 'digest/sha1'

begin
  require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
rescue
  nil
end

class User
  include AuthenticatedSystem::Model
  include DataMapper::Resource
  include DataMapper::Validate

  attr_accessor :password, :password_confirmation

  property :id,                         Integer, :key => true, :serial => true
  property :login,                      String, :length => 30
  property :email,                      String, :length => 255
  property :crypted_password,           String
  property :salt,                       String
  property :remember_token_expires_at,  DateTime
  property :remember_token,             String
  property :time_zone,                  String, :default => 'CET'
  property :created_at,                 DateTime
  property :updated_at,                 DateTime
  property :name,                       String, :length => 60
  property :default_formatter,          String

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