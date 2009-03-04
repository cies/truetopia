class Step
  include DataMapper::Resource
  after :save, :create_discussion

  property :project_id,    Integer, :key => true
  property :number,        Integer, :key => true, :length => 10
  property :created_at,    DateTime

  has 1, :discussion, :class_name => 'StepDiscussion'
  has n, :documents,  :class_name => 'StepDocument'

  belongs_to :project


  private
  def create_discussion
    raise "Couldn't create StepDicussion" unless StepDiscussion.new(:project_id => project_id, :number => number).save
  end
end