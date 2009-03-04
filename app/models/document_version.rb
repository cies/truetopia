class DocumentVersion
  include DataMapper::Resource
  before :save, :render_content_html

  property :document_id,   Integer, :key => true, :writer => :private  # through document=
  property :number,        Integer, :key => true, :writer => :private  # through document=
  property :user_id,       Integer, :nullable => false
  property :title,         String,  :nullable => false, :length => 255
  property :content,       Text,    :nullable => false
  property :content_html,  Text
  property :formatter,     String,  :length => 15
  property :created_at,    DateTime
  property :comment,       Text  # nullable, but has to be valid

  validates_with_method :content, :method =>  :check_for_duplication
  validates_present     :title
  validates_present     :content
  validates_present     :comment
  validates_length      :title,   :min => 5
  validates_length      :title,   :max => 200
  validates_length      :content, :min => 20

  belongs_to :document
  belongs_to :user

  # the inferred validations should be enough
  

  alias :old_document_setter :document=
  def document= (obj)
    old_document_setter obj
    self.number = DocumentVersion.count(:document_id => obj.id) + 1
  end

  private

  def render_content_html
    if formatter == 'MediaCloth'
      # do shit
      return
    end
    # default to plain text
    self.content_html = '<p>'+Haml::Helpers.html_escape(content).gsub("\n", '<br/>')+'</p>'
  end

  def check_for_duplication
    previous = DocumentVersion.first(:document_id => self.document_id, :order => [:created_at.desc])
    return true if not previous
    if previous.title == self.title and previous.content == self.content
      return [false, :duplication]
    end
    return true
  end
end
