class Project
  include DataMapper::Resource
  after :save, :create_initial_step

  property :id,         Serial
  property :created_at, DateTime
  property :user_id,    Integer, :nullable => false
  property :in_step,    Integer, :nullable => false, :length => 10, :default => 0

  belongs_to :user

  has 3, :steps
  has n, :plans, :order => [:created_at.desc]
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

  # this is the most given name (oldest is preferred when more than one name is given most) and
  # the times this name was picked in an array.
  def default_name
    result = repository.adapter.query(%q{
      SELECT name, COUNT(*) AS count FROM subscriptions  -- Project.name
       WHERE discriminator = 'ProjectSubscription' GROUP BY name ORDER BY created_at LIMIT 1})
    return result.blank? ? nil : result[0]
  end

  private
  def create_initial_step
    return unless in_step == 0  # only for 0
    self.in_step = 1
    if Step.new(:project_id => id, :number => in_step).save
      save  # in_step is 1 now...
    else
      raise "Couldn't create step for project ##{id}"
    end
  end
end