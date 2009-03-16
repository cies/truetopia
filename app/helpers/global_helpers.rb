module Merb
  module GlobalHelpers

    def render_object_title_html(obj)
      result = case obj.class
        when User        then link_to obj.login, url(:user, :login => obj.login)
        when Project     then link_to obj.title, url(:project, :id => obj.id)
        when Document    then link_to obj.title, url(:document, :id => obj.id)
        when AgendaItem  then link_to obj.title, url(:agenda_item, :id => obj.id)
        when Discussion  then
          o = obj.discussable_obj
          case obj.discussabe_type
            when 'Document' then link_to "discussie voor document '#{o.title}'", url(:document_discussion, :id => o.id)
            when 'Project'  then link_to "discussie voor project '#{o.title}'", url(:project_discussion, :project_id => o.id)
            when 'Step'     then link_to "discussie voor stap #{o.number} van project '#{o.project.title}'", url(:step_discussion, :project_id => o.project.id, :number => o.number)
          end
        when Post        then
          o = obj.discussion.discussable_obj
          case obj.discussion.discussabe_type
            when 'Document' then link_to "reactie in discussie voor document '#{o.title}'", url(:document_discussion_post, :id => o.id)
            when 'Project'  then link_to "reactie in discussie voor project '#{o.title}'", url(:project_discussion_post, :project_id => o.id)
            when 'Step'     then link_to "reactie in discussie voor stap #{o.number} van project '#{o.project.title}'", url(:step_discussion_post, :project_id => o.project.id, :number => o.number)
          end
        else nil
      end
    end

    def document_url(*options)
      options, aggr = (options[0] or {}), (options[0] ? params.dup.merge(options[0]) : params)
      return case aggr[:parent]
        when 'Step' then options[:document_id] ?
          url(:step_document, aggr[:project_id], aggr[:step], options) :
          url(:step_documents, aggr[:project_id], aggr[:step], options)
      else
        raise "no document_url for #{aggr[:parent].inspect}"
      end
    end

    def discussion_url(*options)
      options, aggr = (options[0] or {}), (options[0] ? params.dup.merge(options[0]) : params)
      return case aggr[:parent]
        when 'Step' then options[:code] ?
          url(:step_discussion_post, aggr[:project_id], aggr[:step], options) :
          url(:step_discussion, aggr[:project_id], aggr[:step], options)
        when 'StepDocument' then options[:code] ?
          url(:step_document_discussion_post, aggr[:project_id], aggr[:step], aggr[:document_id], options) :
          url(:step_document_discussion, aggr[:project_id], aggr[:step], aggr[:document_id], options)
        when 'UserDocument' then options[:code] ?
          url(:user_document_discussion_post, aggr[:login], aggr[:document_id], options) :
          url(:user_document_discussion, aggr[:login], aggr[:document_id], options)
      else
        raise "no discussion_url for #{aggr[:parent].inspect}"
      end
    end

    def form_label(for_object, for_col, title, body='', error_msg='')
      error = ((!for_object.nil?) && for_object.respond_to?(:errors) && for_object.errors.on(for_col))
      "<label for=\"#{for_col}\" #{error ? 'class = "error"' : ''}><span class=\"title\">#{title}</span>#{body}<br />#{error ? "<span class=\"error_msg\">#{error_msg}</span>" : ''}</label>"
    end

    ##
    # This escapes the specified url
    def escape_url(url)
      CGI.escape(url)
    end


    def breadcrums
      html, link_url = '', ''
      separator_html = '<span class="crum_separator">/</span>'
      request.path.split('/')[1..-1].each do |part|
        crum_html = "<span class=\"crum\"><a href=\"#{link_url << '/' + part}\">#{part}</a></span>"
        html << separator_html + crum_html
      end
      html
    end

    def debug_info
      [
        {:name => 'merb_config', :code => 'Merb::Config.to_hash', :obj => Merb::Config.to_hash},
        {:name => 'params', :code => 'params.to_hash', :obj => params.to_hash},
        {:name => 'session', :code => 'session.to_hash', :obj => session.to_hash},
        {:name => 'cookies', :code => 'cookies', :obj => cookies},
        {:name => 'request', :code => 'request', :obj => request},
        {:name => 'exceptions', :code => 'request.exceptions', :obj => request.exceptions},
        {:name => 'env', :code => 'request.env', :obj => request.env},
        {:name => 'routes', :code => 'Merb::Router.routes', :obj => Merb::Router.routes},
        {:name => 'named_routes', :code => 'Merb::Router.named_routes', :obj => Merb::Router.named_routes},
        {:name => 'resource_routes', :code => 'Merb::Router.resource_routes', :obj => Merb::Router.resource_routes},
      ]
    end
  end
end
