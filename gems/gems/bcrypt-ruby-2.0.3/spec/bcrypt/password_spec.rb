require File.join(File.dirname(__FILE__), "..", "spec_helper")

context "Creating a hashed password" do
  
  setup do
    @secret = "wheedle"
    @password = BCrypt::Password.create(@secret, :cost => 4)
  end
  
  specify "should return a BCrypt::Password" do
    @password.should be_an_instance_of(BCrypt::Password)
  end
  
  specify "should return a valid bcrypt password" do
    lambda { BCrypt::Password.new(@password) }.should_not raise_error
  end
  
  specify "should behave normally if the secret not a string" do
    lambda { BCrypt::Password.create(nil) }.should_not raise_error(BCrypt::Errors::InvalidSecret)
    lambda { BCrypt::Password.create({:woo => "yeah"}) }.should_not raise_error(BCrypt::Errors::InvalidSecret)
    lambda { BCrypt::Password.create(false) }.should_not raise_error(BCrypt::Errors::InvalidSecret)
  end
end

context "Reading a hashed password" do
  setup do
    @secret = "U*U"
    @hash = "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
  end
  
  specify "should read the version, cost, salt, and hash" do
    password = BCrypt::Password.new(@hash)
    password.version.should eql("2a")
    password.cost.should equal(5)
    password.salt.should eql("$2a$05$CCCCCCCCCCCCCCCCCCCCC.")
    password.to_s.should eql(@hash)
  end
  
  specify "should raise an InvalidHashError when given an invalid hash" do
    lambda { BCrypt::Password.new('weedle') }.should raise_error(BCrypt::Errors::InvalidHash)
  end
end

context "Comparing a hashed password with a secret" do
  setup do
    @secret = "U*U"
    @hash = "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
    @password = BCrypt::Password.create(@secret)
  end
  
  specify "should compare successfully to the original secret" do
    (@password == @secret).should be(true)
  end
  
  specify "should compare unsuccessfully to anything besides original secret" do
    (@password == "@secret").should be(false)
  end
end