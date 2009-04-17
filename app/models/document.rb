
# this class is abstract, so never used directly
# use its subclasses instead
class Document
  include DataMapper::Resource
  before :valid?, :set_number
  after  :save,   :create_discussion

  attr_reader :current_version, :current_version_number

  property :id,            Serial
  property :created_at,    DateTime
  property :updated_at,    DateTime
  property :user_id,       Integer, :nullable => false
  property :number,        Integer, :writer => :private
  property :discriminator, Discriminator  # because this model is subclassed

  # properties for UserDocument (cannot create indices on subclassed models)
  property :user_id,              Integer, :unique_index => :user_document_handle
  property :user_document_number, Integer, :unique_index => :user_document_handle

  # properties for UserDocument (cannot create indices on subclassed models)
  property :project_id,           Integer, :unique_index => :step_document_handle
  property :step_number,          Integer, :unique_index => :step_document_handle, :length => 10  # cannot be called :step
  property :step_document_number, Integer, :unique_index => :step_document_handle

  belongs_to :user
  has n, :versions, :class_name => 'DocumentVersion', :order => [:number.desc]
  has 1, :discussion, :class_name => 'DocumentDiscussion'

#   def discussion
#     DocumentDiscussion.first(:document_id => id)
#   end

#   def version_count
#     DocumentVersion.count(:document_id => id)
#   end

  def current_version
    get_current_version
  end

  def current_version_number=(n)
    get_current_version(n)
  end

  def diff(from_version, to_version, property = :content_html)
    line_separator = {:content_html => /<br\s*[\/]{0,1}\s*>/}[property] or /\r*\n/
    from_arr = (from_version.send(property) or '').split(line_separator)
    to_arr   = (to_version.send(property) or '').split(line_separator)
    sdiff = Diff::LCS.sdiff(from_arr, to_arr)
  end

  def context; raise NotImplementedError; end
  def number;  raise NotImplementedError; end

  private
  def get_current_version(n = nil)
    # when n is nil it returns the current, if no current is set it returns the latest version
    n ||= @current_version ? @current_version.number : versions.count
    # make sure this gets only pulled from the db once
    return @current_version if @current_version and @current_version.number == n
    @current_version = DocumentVersion.get(id, n) or raise NotFound
  end

  def create_discussion
    raise "Couldn't create DocumentDicussion" unless DocumentDiscussion.new(:document_id => id).save
  end

  def set_number
    self.number = context.documents.count + 1 if number.blank? or new_record?
  end
end


class UserDocument < Document
  property :published, Boolean  # cannot set :nullable => false, so using a validation
  belongs_to :user
  validates_present :user, :user_document_number, :published

  alias :number  :user_document_number
  alias :number= :user_document_number=
  def context; user; end
end

class StepDocument < Document
  has n, :votes, :child_key => [:step_document_id]
  belongs_to :step1_document, :class_name => 'StepDocument'  # foundation documents where applicable
  belongs_to :step2_document, :class_name => 'StepDocument'
  belongs_to :project
  belongs_to :step, :parent_key => [:project_id, :number], :child_key => [:project_id, :step_number]  # WORKS!!
  validates_present :user, :project, :step, :step_document_number

  alias :number  :step_document_number
  alias :number= :step_document_number=
  def context; step; end
end
