class Project
  include DataMapper::Resource
  include DataMapper::Validate

  property :id,         Integer, :key => true, :serial => true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :user_id,    Integer, :nullable => false
  property :step,       Integer, :nullable => false, :length => 10, :default => 0

  belongs_to :user
  # has 1, :description_document, :class_name => 'Document' -- the doc type has to be set
  # has one discussion through a polymorphic, non-datamapper, relation

  has 1, :project_document  # the discussion of this doc is the 'project discussion'
  has 3, :steps

  after :save do
    create_initial_step
  end

#   def create_step
#     if [1,2].include? step
#       step += step
#     elsif step == 3
#       return
#     else
#       step = 1
#     end
#     raise "Step number #{step} already exists for project ##{id}" if Step.first(:project_id => id, :number => step)
#     raise "Illegal step number #{step}" unless [1,2,3].include? step
#     raise "Couldn't create step for project ##{id}" unless Step.create(:project_id => id, :number => step)
#     raise "Couldn't save step change for project ##{id}" unless save
#   end

  private
  def create_initial_step
    raise "This is not the initial step, but step numer #{step}" if [1,2,3].include? step
    step = 1
    unless Step.new(:project_id => id, :number => step).save
      Project[id].destroy
      raise "Couldn't create step for project ##{id}, this shouldn't happen, destroyed project for consitency"
    end
  end


#   # this method is just a shortcut to Project.project_document.current_version
#   def doc
#     # make sure this gets only pulled once from the db
#     return @doc if @doc
#     @doc = ProjectDocument.first(:project_id => id).current_version
#     raise "No ProjectDocument for project ##{self.id}." unless @doc
#     return @doc
#   end
end