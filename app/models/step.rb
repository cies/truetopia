class Step
  include DataMapper::Resource
  include DataMapper::Validate  # we make indirect use of it (auto validation)

  property :project_id,    Integer, :key => true
  property :number,        Integer, :key => true, :length => 10
  property :created_at,    DateTime

  # has a discussion, not dm managed
  # has many documents, not dm managed

  belongs_to :project

  after :save do
    create_discussion
  end

  def discussion
    StepDiscussion.first(:project_id => project_id, :number => number)
  end

  def documents
    StepDocument.all(:project_id => project_id, :number => number)
  end

  private
  def create_discussion
    raise "Couldn't create StepDicussion" unless StepDiscussion.new(:project_id => project_id, :number => number).save
  end
end