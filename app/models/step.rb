class Step
  include DataMapper::Resource
  after :save, :create_discussion

  property :project_id,    Integer, :key => true
  property :number,        Integer, :key => true, :length => 10
  property :created_at,    DateTime

  has 1, :discussion, :class_name => 'StepDiscussion', :child_key => [:project_id, :step_number]
  has n, :documents,  :class_name => 'StepDocument', :child_key => [:project_id, :step_number] #, :step => number

  belongs_to :project

  def document(n)
    StepDocument.first(:project_id => project_id, :step_number => number, :step_document_number => n)
  end

#   def documents  # the dm associations messes it up, therefor reimplmented
#     StepDocument.all(:project_id => project_id, :step => number)
#   end

  private
  def create_discussion
    raise "Couldn't create StepDiscussion" unless StepDiscussion.new(:project => project, :step_number => number).save
  end
end

