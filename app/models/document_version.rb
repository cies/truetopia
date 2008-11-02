class DocumentVersion
  include DataMapper::Resource
  include DataMapper::Validate  # we make indirect use of it (auto validation)

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

  validates_present     :title,   :message => :needs_title
  validates_present     :content, :message => :needs_content
  validates_present     :comment, :message => :needs_comment

  validates_length      :title,   :min => 5,   :message => :title_too_short
  validates_length      :title,   :max => 200, :message => :title_too_long
  validates_length      :content, :min => 20,  :message => :content_too_short


  belongs_to :document
  belongs_to :user

  before :save do
    render_content_html
  end

  # the inferred validations should be enough
  

  alias :old_document_setter document=
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

#   property :content, :text
#   property :content_html, :text
#   property :created_at, :datetime
#   property :moderated, :boolean, :default => false
#   property :number, :integer
#   property :spam, :boolean, :default => false
#   property :spaminess, :float, :default => 0
#   property :signature, :string
#   
#   belongs_to :document
#   
#   before_save :populate_content_html
#  
#   validates_presence_of :content
#  
#   def spam_or_ham
#     spam? ? 'spam' : 'ham'
#   end
#   
#   def self.most_recent_unmoderated(max=100)
#     all(:moderated => false, :limit => max, :order => 'created_at DESC')
#   end
#   
#   def self.latest_version_for_page(page)
#     first(:page_id => page.id, :order => 'number DESC', :spam => false)
#   end
#   
#   def self.create_spam(page_name, options={})
#     create(
#       options.update(
#         :spam => true,
#         :page_id => -1,
#         :content => [options[:content], page_name].join(':')
#       )
#     )
#   end
#   
#   def self.recent(number = 10)
#     all(:limit => number, :order => 'id DESC', :spam => false)
#   end
#  
#   # Generate the diff between the version and another
#   # send by params
#   # You can define the format, by default is unified
#   # if other_version is nil, return ""
#   def diff(other_version, format=:unified)
#     Diff.cs_diff(content_html, other_version.content_html, :unified, 0) unless other_version.nil?
#   end
#  
#   # Get the previous version for this page
#   # If there are no version previous, return null
#   def previous
#     page.versions.find do |version|
#       version.number == (self.number - 1)
#     end
#   end
#   
# private
#   def linkify_bracketed_phrases(string)
#     string.gsub(/\[\[([^\]]+)\]\]/) { "<a href=\"/pages/#{Page.slug_for($1.strip)}\">#{$1.strip}</a>" }
#   end
#  
#   def populate_content_html
#     content_with_internal_links = linkify_bracketed_phrases(content)
#     self.content_html = RedCloth.new(content_with_internal_links).to_html
#   end
# end
# 
# 
# 
# ### FROM collective
# # 
# # class Version < DataMapper::Base
# #   property :content, :text
# #   property :content_html, :text
# #   property :created_at, :datetime
# #   property :moderated, :boolean, :default => false
# #   property :number, :integer
# #   property :spam, :boolean, :default => false
# #   property :spaminess, :float, :default => 0
# #   property :signature, :string
# #   
# #   belongs_to :page
# #   
# #   before_save :populate_content_html
# #  
# #   validates_presence_of :content
# #  
# #   def spam_or_ham
# #     spam? ? 'spam' : 'ham'
# #   end
# #   
# #   def self.most_recent_unmoderated(max=100)
# #     all(:moderated => false, :limit => max, :order => 'created_at DESC')
# #   end
# #   
# #   def self.latest_version_for_page(page)
# #     first(:page_id => page.id, :order => 'number DESC', :spam => false)
# #   end
# #   
# #   def self.create_spam(page_name, options={})
# #     create(
# #       options.update(
# #         :spam => true,
# #         :page_id => -1,
# #         :content => [options[:content], page_name].join(':')
# #       )
# #     )
# #   end
# #   
# #   def self.recent(number = 10)
# #     all(:limit => number, :order => 'id DESC', :spam => false)
# #   end
# #  
# #   # Generate the diff between the version and another
# #   # send by params
# #   # You can define the format, by default is unified
# #   # if other_version is nil, return ""
# #   def diff(other_version, format=:unified)
# #     Diff.cs_diff(content_html, other_version.content_html, :unified, 0) unless other_version.nil?
# #   end
# #  
# #   # Get the previous version for this page
# #   # If there are no version previous, return null
# #   def previous
# #     page.versions.find do |version|
# #       version.number == (self.number - 1)
# #     end
# #   end
# #   
# # private
# #   def linkify_bracketed_phrases(string)
# #     string.gsub(/\[\[([^\]]+)\]\]/) { "<a href=\"/pages/#{Page.slug_for($1.strip)}\">#{$1.strip}</a>" }
# #   end
# #  
# #   def populate_content_html
# #     content_with_internal_links = linkify_bracketed_phrases(content)
# #     self.content_html = RedCloth.new(content_with_internal_links).to_html
# #   end
# # end