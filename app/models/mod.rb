class Mod
  include DataMapper::Validate
  include DataMapper::Resource

  MODDABLE_TYPES = %w{Document Project Post}

  property :moddable_id,       Integer, :key => true
  property :moddable_type,     String,  :key => true, :length => 20
  property :user_id,           Integer, :key => true
  property :created_at,        DateTime
  property :comment,           Text
  property :target_user_id,    Integer, :nullable => false

  ## this class still need a loooooooooooad of thoughtworks, and field research (slashdot/geenstijl)

  def self.moddable_types
    MODDABLE_TYPES
  end
end