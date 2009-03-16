REPLY_PREFIX = 'Re:'

class DiscussionPosts < Application
#   cache_pages :index, :show

  def index
    get_context
    @root_posts = @discussion.root_posts
    render
  end

  def index_redirect
    redirect request.uri[0..(request.uri =~ /\/[^\/.,;?]+$/)]  # chomp off the last bit of the path
  end

  def new
    get_context
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

  def show
    get_context
    @discussion = @document.discussion
    @post = Post.first(:discussion_id => @discussion.id, :code => params[:code])
    render
  end

  private
  def get_context
    case params[:parent]
      when 'Step'
        @project = Project.get(params[:project_id]) or raise NotFound
        @step = @project.step(params[:step]) or raise NotFound
        @discussion = @step.discussion or raise NotFound
      when 'StepDocument'
        @project = Project.get(params[:project_id]) or raise NotFound
        @step = @project.step(params[:step]) or raise NotFound
        @document = Document.get(params[:document_id]) or raise NotFound
        @discussion = @document.discussion or raise NotFound
      else
        raise "No context to be loaded for #{params[:parent]}"
    end
  end

  def reply_prefix(str)
    return str if str[0..(REPLY_PREFIX.length-1)] == REPLY_PREFIX  # don't add blindly "Re: Re: Re: subject"
    return "#{REPLY_PREFIX} #{str}"
  end
end
