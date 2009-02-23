REPLY_PREFIX = 'Re:'

class Discussions < Application
#   cache_pages :index, :show

  def show
    get_base
    @discussion = @document.discussion
    @root_posts = @discussion.root_posts
    display @root_posts
  end

  def new_post
    get_base
    @discussion = @document.discussion
    if params[:parent_code]
      @parent_post = Post.first(:discussion_id => @discussion.id, :code => params[:parent_code])
    else
      @parent_post = nil
    end
    if request.env['REQUEST_METHOD'] == "POST"
      @post = Post.new(params['post'])
      @post.parent_code = params[:parent_code]  # could be nil therefore root post
      @post.discussion_id = @discussion.id
      @post.user = session.user
      @post.set_number_and_code
      if @post.save
        redirect url("#{params[:base]}_discussion".to_sym, "#{params[:base]}_id".to_sym => params["#{params[:base]}_id".to_sym])
      else
        display @post
      end
    else
      if @parent_post
        @post = Post.new(:title => reply_prefix(@parent_post.title))
      else
        @post = Post.new
      end
      display @post
    end
  end

  def view_post
    get_base
    @discussion = @document.discussion
    @post = Post.first(:discussion_id => @discussion.id, :code => params[:code])
    display @post
  end

  private
  def get_base
    case params[:base]
      when 'project'
        @project = Project[params[:project_id]]
        @document = @project.project_document
      when 'user'
        
    end
  end

  def reply_prefix (str)
    return str if str[0..(REPLY_PREFIX.length-1)] == REPLY_PREFIX
    return "#{REPLY_PREFIX} #{str}"
  end
end
