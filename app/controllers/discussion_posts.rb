REPLY_PREFIX = 'Re:'

class DiscussionPosts < Application

  def index
    get_context
    @root_posts = @discussion.root_posts
    render
  end

  def index_redirect  # for path safety
   redirect discussion_url
  end

  def new(post = nil)
    get_context
    @parent_post = Post.first(:discussion_id => @discussion.id, :code => params[:parent_code]) if params[:parent_code]
    if post
      @post = Post.new(post)  # parent_code is set through a hidden value
      @post.discussion_id = @discussion.id
      @post.user = session.user
      if @post.save
        redirect discussion_url
      else
        render
      end
    else
      @parent_post ?
        @post = Post.new(:title => reply_prefix(@parent_post.title)) :
        @post = Post.new
      render
    end
  end

  def show(code)
    get_context
    @post = Post.first(:discussion_id => @discussion.id, :code => code) or raise NotFound
    render
  end

  private
  def get_context
    case params[:discussion_parent]
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
