class Projects < Application
#   cache_pages :index, :show

  def index
    @projects = Project.all
#     @projects = Project.paginate(:page => params[:page], :per_page => 10, :order => [:updated_at.desc])
    render
  end

  def index_redirect  # for path safety
   redirect url(:projects) 
  end

  def show(project_id)
    @project = Project.get(project_id)
    render
  end

  def show_redirect(project_id)  # for path safety
   redirect url(:project, project_id)
  end

  def step(project_id, step)
    @project = Project.get(project_id)
    @step = @project.step(step) or NotFound
    render
  end

  def new(project_subscription = nil, step1_document = nil)
    if project_subscription  # after submitting the 1st form
      @project = Project.new(:user_id => session.user.id)
      raise "Couldn't save initial project: #{@project.errors.inspect}" unless @project.save
      @project_subscription = ProjectSubscription.new(:subscribable_id => @project.id, :user_id => session.user.id)
      @project_subscription.name = project_subscription[:name]
      if @project_subscription.save
        render :new_finished
      else
        render
      end
    else  # showing the 1st form
      @project_subscription = ProjectSubscription.new
      render
    end
  end
end
