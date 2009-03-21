# require 'diff/lcs'

class Document
  include DataMapper::Resource
  after :save, :create_discussion

  property :id,            Serial
  property :created_at,    DateTime
  property :updated_at,    DateTime
  property :user_id,       Integer, :nullable => false
  property :discriminator, Discriminator  # because this model is subclassed

  belongs_to :user
  has n, :versions, :class_name => 'DocumentVersion', :order => [:number.desc]
  has 1, :discussion, :class_name => 'DocumentDiscussion', :child_key => [:document_id]
  # has one discussion through a polymorphic, non-datamapper, relation

#   def discussion
#     DocumentDiscussion.first(:document_id => id)
#   end

  def version_count
    DocumentVersion.count(:document_id => id)
  end

  def current_version
    get_current_version
  end

  def version(number)
    DocumentVersion.first(:document_id => id, :number => number)
  end

  def diff(from_version, to_version, property = :content_html)
    line_separator = {:content_html => /<br\s*[\/]{0,1}\s*>/}[property] or /\r*\n/
    from_arr = (from_version.send(property) or '').split(line_separator)
    to_arr   = (to_version.send(property) or '').split(line_separator)
    sdiff = Diff::LCS.sdiff(from_arr, to_arr)
  end

  private

  def get_current_version
    # make sure this gets only pulled once from the db
    return @current_version if @current_version
    @current_version = DocumentVersion.first(:document_id => self.id, :order => [:number.desc])
    raise "No current version for document ##{self.id}." unless @current_version
    return @current_version
  end

  def create_discussion
    raise "Couldn't create StepDicussion" unless DocumentDiscussion.new(:document_id => id).save
  end
end


class UserDocument < Document
  property :published, Boolean  # cannot set :nullable => false, so using a validation

  validates_present :published
end


class StepDocument < Document
  belongs_to :project
  validates_present :project

  def votes
    StepDocumentVotes.all(:step_document_id => id)
  end

  def step
    Step.get(:project_id => project_id, :number => discriminator[/\d+/])
  end
end

class Step1Document < StepDocument; end
class Step2Document < StepDocument; end
class Step3Document < StepDocument; end
