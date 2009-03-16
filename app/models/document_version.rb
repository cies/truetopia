class DocumentVersion
  include DataMapper::Resource
  before :valid?, :set_version_number
  before :save,   :render_content_html

  property :document_id,   Integer, :key => true
  property :number,        Integer, :key => true
  property :user_id,       Integer, :nullable => false
  property :title,         String,  :nullable => false, :length => 255
  property :content,       Text,    :nullable => false
  property :content_html,  Text
  property :formatter,     String,  :length => 15
  property :created_at,    DateTime
  property :comment,       Text  # nullable, but has to be valid

  validates_with_method :content, :method => :check_for_duplication
  validates_with_method :comment, :method => :comment_present_for_all_but_number_one
  validates_present     :title
  validates_present     :content
  validates_length      :title,   :min => 5
  validates_length      :title,   :max => 200
  validates_length      :content, :min => 20

  belongs_to :document
  belongs_to :user


  private

  def render_content_html
    if formatter == 'MediaCloth'
      # do shit
      return
    end
    # default to plain text
    self.content_html = '<p>'+Haml::Helpers.html_escape(content).gsub("\n", '<br/>')+'</p>'
  end

  def set_version_number
    self.number = document.versions.count + 1
  end

  def check_for_duplication
    previous = DocumentVersion.first(:document_id => document_id, :order => [:created_at.desc])
    return true if not previous
    return [false, :nothing_has_changed] if previous.title == title and previous.content == content
    return true
  end
  def comment_present_for_all_but_number_one
    return [false, :please_add_comment] if comment.blank? and number > 1
    return true
  end
end
