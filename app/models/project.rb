class Project
  include DataMapper::Resource
  after :save, :create_initial_step

  property :id,         Integer, :key => true, :serial => true
  property :created_at, DateTime
  property :user_id,    Integer, :nullable => false
  property :in_step,    Integer, :nullable => false, :length => 10, :default => 0

  belongs_to :user

  has 3, :steps

  def discussion
    document.discusion
  end

  private
  def create_initial_step
    raise "This is not the initial step, but step numer #{in_step}" if [1,2,3].include? in_step  # only for 0
    step = 1
    unless Step.new(:project_id => id, :number => in_step).save
      raise "Couldn't create step for project ##{id}, this shouldn't happen" 
    end
  end
end