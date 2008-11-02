# require 'diff/lcs'

class Document
  include DataMapper::Resource
  include DataMapper::Validate
#   include MerbPaginate::Finders::Datamapper

  property :id,            Integer, :key => true, :serial => true
  property :created_at,    DateTime
  property :updated_at,    DateTime
  property :user_id,       Integer, :nullable => false
  property :discriminator, Discriminator  # because this model is subclassed

  belongs_to :user
  has n, :versions, :class_name => 'DocumentVersion'
  # has one discussion through a polymorphic, non-datamapper, relation

  after :save do
    create_discussion
  end

  def discussion
    DocumentDiscussion.first(:document_id => id)
  end

  def version_count
    DocumentVersion.count({:document_id => id})
  end

  def current_version
    get_current_version
  end

  def version(number)
    v = DocumentVersion.first(:document_id => id, :number => number)
    raise "No version ##{number} exists for document ##{id}" unless v
    return v
  end
private

  def get_current_version
    # make sure this gets only pulled once from the db
    return @current_version if @current_version
    @current_version = DocumentVersion.first(:document_id => self.id, :number => self.version_count)
    raise "No current version for document ##{self.id}." unless @current_version
    return @current_version
  end

  def create_discussion
    raise "Couldn't create StepDicussion" unless DocumentDiscussion.new(:document_id => id).save
  end
end


class UserDocument < Document
  property :published, Boolean # cannot set :nullable => false, so using a validation

  validates_present :published
end


class StepDocument < Document
  STAGES = %w{indevelopment final}  # only final docs are votable

  property :project_id, Integer # cannot set :nullable => false, so using a validation
  property :step,       Integer # cannot set :nullable => false, so using a validation
  property :stage,      String, :default => 'initial'

  validates_present :project_id, :step

  # belongs to step, not dm managed
  belongs_to :project

  def step
    Step.first(:project_id => project_id, :number => step)
  end

  def stage= (new_stage)
    raise "stage has to be a one of #{STAGES.inspect}" unless STAGES.include? new_stage
    if (stage == 'development' and new_stage == 'initial') or (stage == 'final' and new_stage != 'final')
      raise 'cannot change stage back'
    end
    self.stage = new_stage
  end
end


class ProjectDocument < Document
  property :project_id, Integer # cannot set :nullable => false, so using a validation

  validates_present :project_id

  belongs_to :project
end


# class Document
#   include DataMapper::Validate
#   include MerbPaginate::Finders::Datamapper
#   include DataMapper::Resource
#   
#   property :id, Integer, :key => true, :serial => true
#   property :created_at, DateTime
#   property :user_id, Integer, :nullable => false
#   property :versions_count, :integer, :default => 0
#   
#   validates_present :title, :key => "uniq_title"
#   validates_present :content, :key => "uniq_content"
#   validates_present :user_id, :key => "uniq_user_id"
#   
#   belongs_to :user
#   has_many :document_versions, :dependent => :destroy
#   
#   after :create, :set_create_event
#   after :update, :set_update_event
#   
#   before :create, :build_new_version
#   
#   attr_accessor :content_diff
#   def content=(new_content)
#     self.content_diff = diff(new_content)
#     @content = new_content
#   end
#   
#   def content
#     @content ||= selected_version.try(:content) || ''
#   end
#  
#   def content_html
#     selected_version.try(:content_html) || ''
#   end
#  
#   def latest_version
#     DocumentVersion.latest_version_for_page(self)
#   end
#  
#   def select_version!(version_number=:latest)
#     @selected_version = find_selected_version(version_number)
#     self.content = selected_version.try(:content)
#     @selected_version
#   end
#  
#   def selected_version
#     @selected_version || latest_version
#   end
#  
# private
#   def diff(new_content)
# #     diff = Diff::LCS.sdiff(content, new_content)
# #     all_changes = diff.reject { |diff| diff.unchanged? }
# #     additions = all_changes.reject { |diff| diff.deleting? }
# #     additions.map { |diff| diff.to_a.last.last }.join
#   end
#  
#   def build_new_version
#     # DataMapper not initializing versions_count with default value of zero. Bug?
#     self.versions_count ||= 0
#     self.versions_count += 1
#     
#     # Don't use #build as it is NULLifying the page_id field of this page's other versions
#     versions.create(version_attributes)
#   end
#   
#   def find_selected_version(version_number)
#     if version_number.nil? || version_number == :latest
#       latest_version
#     else
#       version_number = version_number.to_i
#       versions.detect { |version| version.number == version_number }
#     end
#   end
#   
#   def version_attributes
#     defaults = {
#       :content => content,
#       :remote_ip => remote_ip,
#       :signature => signature
#     }
#     defaults.update(:number => versions_count)
#   end
#  
# end


### FROM feather
# 
# class Document
#   include DataMapper::Validate
#   include MerbPaginate::Finders::Datamapper
#   include DataMapper::Resource
#   
#   property :id, Integer, :key => true, :serial => true
#   property :created_at, DateTime
#   property :user_id, Integer, :nullable => false
#   
#   validates_present :title, :key => "uniq_title"
#   validates_present :content, :key => "uniq_content"
#   validates_present :user_id, :key => "uniq_user_id"
#   
#   belongs_to :user
#   
#   # Core filters
#   before :update, :set_published_permalink
#   after :create, :set_create_event
#   after :update, :set_update_event
#   
#   
#   ##
#   # This sets the published date and permalink when an article is published
#   def set_published_permalink
#     # Check to see if we are publishing
#     if self.is_published?
#       # Set the date, only if we haven't already
#       self.published_at = Time.now if self.published_at.nil?
#       
#       # Set the permalink, only if we haven't already
#       self.permalink = create_permalink
#     end
#     true
#   end
#  
#   def set_create_event
#     if new_record?
#       e = Event.new
#       e.message = "Article \"#{self.title}\" created"
#       e.save
#     end
#   end
#  
#   def set_update_event
#     unless new_record?
#       e = Event.new
#       e.message = "Article \"#{self.title}\" updated"
#       e.save
#     end
#   end
# 
#   def is_published?
#     # We need this beacuse the values get populated from the params
#     self.published == "1" || self.published
#   end
#   
#   def create_permalink
#     permalink = "/:year/:month/:day/:title".gsub(/:year/,self.published_at.year.to_s)
#     permalink.gsub!(/:month/,Padding::pad_single_digit(self.published_at.month))
#     permalink.gsub!(/:day/,Padding::pad_single_digit(self.published_at.day))
#     
#     title = self.title.gsub(/\W+/, ' ') # all non-word chars to spaces
#     title.strip! # ohh la la
#     title.downcase! #
#     title.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
#     permalink.gsub!(/:title/,title)
#     
#     permalink
#   end
#  
#   class << self
#     ##
#     # Custom finders
#  
#     def find_recent
#       self.all(:published => true, :limit => 10, :order => [:published_at.desc])
#     end
#  
#     def find_by_year(year)
#       self.all(:published_at.like => "#{year}%", :published => true, :order => [:published_at.desc])
#     end
#  
#     def find_by_year_month(year, month)
#       month = Padding::pad_single_digit(month)
#       self.all(:published_at.like => "#{year}-#{month}%", :published => true, :order => [:published_at.desc])
#     end
#  
#     def find_by_year_month_day(year, month, day)
#       month = Padding::pad_single_digit(month)
#       day = Padding::pad_single_digit(day)
#       self.all(:published_at.like => "#{year}-#{month}-#{day}%", :published => true, :order => [:published_at.desc])
#     end
#  
#     def find_by_permalink(permalink)
#       self.first(:permalink => permalink)
#     end
#  
#     def get_archive_hash
#       counts = self.find_by_sql("SELECT COUNT(*) as count, #{specific_date_function} FROM articles WHERE published_at IS NOT NULL AND published = 1 GROUP BY year, month ORDER BY year DESC, month DESC")
#       archives = counts.map do |entry|
#         {
#           :name => "#{Date::MONTHNAMES[entry.month.to_i]} #{entry.year}",
#           :month => entry.month.to_i,
#           :year => entry.year.to_i,
#           :article_count => entry.count
#         }
#       end
#       archives
#     end
#  
#     private
#       def specific_date_function
#         # This is pretty nasty loading up the db.yml to get at this, but I wasn't able to find the method in merb just yet. Change it!
#         if YAML::load(File.read("config/database.yml"))[Merb.environment.to_sym][:adapter] == 'sqlite3'
#           "strftime('%Y', published_at) as year, strftime('%m', published_at) as month"
#         else
#           "extract(year from published_at) as year, extract(month from published_at) as month"
#         end
#       end
#   end
# end








### FROM collective
# 
# require 'diff/lcs'
#  
# class Page < DataMapper::Base
#   property :name, :string, :nullable => false
#   attr_accessor :spam
#   attr_accessor :spaminess
#   attr_accessor :remote_ip
#   attr_accessor :signature
#   property :slug, :string, :nullable => false
#   property :versions_count, :integer, :default => 0
#   has_many :versions, :spam => false, :dependent => :destroy
#   
#   before_save :build_new_version
#   before_validation :set_slug
#  
#   validates_uniqueness_of :slug
#   validates_uniqueness_of :name
#  
#   def self.by_slug(slug)
#     first(:slug => slug)
#   end
#   
#   def self.by_slug_and_select_version!(slug, version)
#     page = by_slug(slug)
#     page.select_version!(version) if page
#     
#     # Order matters! This is a little clever. If +try+ fails, +nil+ is
#     # returned, and therefore the search was invalid. If +try+ doesn't fail,
#     # +page+ must have been found and will be returned.
#     return page.try(:selected_version) && page
#   end
#   
#   attr_accessor :content_diff
#   def content=(new_content)
#     self.content_diff = diff(new_content)
#     @content = new_content
#   end
#   
#   def content
#     @content ||= selected_version.try(:content) || ''
#   end
#  
#   def content_html
#     selected_version.try(:content_html) || ''
#   end
#  
#   def latest_version
#     Version.latest_version_for_page(self)
#   end
#  
#   def name=(new_name)
#     @name = new_name if new_record?
#   end
#  
#   def select_version!(version_number=:latest)
#     @selected_version = find_selected_version(version_number)
#     self.content = selected_version.try(:content)
#     @selected_version
#   end
#  
#   def selected_version
#     @selected_version || latest_version
#   end
#  
#   def self.slug_for(name)
#     name = Iconv.iconv('ascii//translit//IGNORE', 'utf-8', name).to_s
#     name.gsub!(/\W+/, ' ') # non-words to space
#     name.strip!
#     name.downcase!
#     name.gsub!(/\s+/, '-') # all spaces to dashes
#     name
#   end
#  
#   def to_param
#     slug
#   end
#  
# private
#   def diff(new_content)
#     diff = Diff::LCS.sdiff(content, new_content)
#     all_changes = diff.reject { |diff| diff.unchanged? }
#     additions = all_changes.reject { |diff| diff.deleting? }
#     additions.map { |diff| diff.to_a.last.last }.join
#   end
#  
#   def build_new_version
#     # DataMapper not initializing versions_count with default value of zero. Bug?
#     self.versions_count ||= 0
#     self.versions_count += 1 unless spam
#     
#     # Don't use #build as it is NULLifying the page_id field of this page's other versions
#     versions.create(version_attributes)
#   end
#   
#   def find_selected_version(version_number)
#     if version_number.nil? || version_number == :latest
#       latest_version
#     else
#       version_number = version_number.to_i
#       versions.detect { |version| version.number == version_number }
#     end
#   end
#   
#   def version_attributes
#     defaults = {
#       :content => content,
#       :remote_ip => remote_ip,
#       :signature => signature
#     }
#     if spam
#       defaults.update(
#         :number => versions_count.succ,
#         :spam => true,
#         :spaminess => spaminess
#       )
#     else
#       defaults.update(:number => versions_count)
#     end
#   end
#  
#   def set_slug
#     self.slug = Page.slug_for(name) if new_record?
#   end
#  
# end