class Project
  include DataMapper::Resource
  after :save, :create_initial_step

  property :id,         Serial
  property :created_at, DateTime
  property :user_id,    Integer, :nullable => false
  property :in_step,    Integer, :nullable => false, :length => 10, :default => 0

  belongs_to :user

  has 3, :steps
  has n, :subscriptions, :child_key => [:subscribable_id], :class_name => 'ProjectSubscription'

  def step(n)
    Step.get(self.id, n)
  end

  # names are given by users through subscriptions
  def names(limit = 10)
    repository.adapter.query(%q{
      SELECT name, COUNT(*) AS count FROM subscriptions  -- Project.names
       WHERE discriminator = 'ProjectSubscription' GROUP BY name ORDER BY count DESC}).map{ |x| x = x.to_a }
  end

  # this is the most given name (oldest is preferred when more than one name is given most)
  def default_name
    result = repository.adapter.query(%q{
      SELECT name, COUNT(*) AS count FROM subscriptions  -- Project.name
       WHERE discriminator = 'ProjectSubscription' GROUP BY name ORDER BY created_at LIMIT 1})
    return result.blank? ? nil : result[0][0]
  end

  private
  def create_initial_step
    raise "This is not the initial step, but step numer #{in_step}" if [1,2,3].include? in_step  # only for 0
    self.in_step = 1
    unless Step.new(:project_id => id, :number => in_step).save
      raise "Couldn't create step for project ##{id}, this shouldn't happen" 
    end
  end
end