class Post
  include DataMapper::Resource
  before :valid?, :set_number_and_code  # number and code are reduced from the parents code and child count, if any

  property :id,            Serial  # needed for Subscription
  property :discussion_id, Integer, :nullable => false
  property :code,          String,  :nullable => false, :length => 40, :writer => :private  # through :set_number_and_code
  property :number,        Integer, :nullable => false, :writer => :private  # through :set_number_and_code
  property :parent_code,   String   # nil when a root post
  property :created_at,    DateTime
  property :user_id,       Integer, :nullable => false
  property :title,         String,  :length => 200
  property :content,       Text
  property :content_html,  Text

  validates_present :title,   :message => :needs_title
  validates_present :content, :message => :needs_content
  validates_length  :title,   :max => 200, :message => :title_too_long

  belongs_to :discussion
  belongs_to :user

  def parent
    Post.first(:discussion_id => discussion_id, :code => parent_code)  # nil if no parent code is set
  end

  def children
    Post.all(:discussion_id => discussion_id, :parent_code => code, :order => [:created_at.asc])
  end

  def children_count
    Post.count(:discussion_id => discussion_id, :parent_code => code)
  end

## from dm-is-tree, but not uncomment what we don't use
#
#   def ancestors
#     node, nodes = self, []
#     nodes << node = node.parent while node.parent
#     nodes.reverse
#   end
# 
#   def generation
#     parent ? parent.children : self.class.roots
#   end
# 
#   def root
#     node = self
#     node = node.parent while node.parent
#     node
#   end
# 
#   def siblings
#     generation - [self]
#   end

  private
  def set_number_and_code
    p '1233333333333333333333333333333333333' unless new_record?
    if parent_code.blank? or parent_code.to_s == '0'  # check if we're making a root post
    p '123333333333333333333333333333333333---'
      self.parent_code = nil
      self.number      = discussion.root_post_count + 1
      self.code        = number.to_s
    else
    p '1233333333333333333333333333333333333---------------'
      @parent     = Post.first(:discussion_id => discussion_id, :code => parent_code)
      self.number = @parent.children_count + 1
      self.code   = "#{parent_code}.#{number.to_s}"
    end
  end
end
