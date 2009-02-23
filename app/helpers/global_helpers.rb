module Merb
  module GlobalHelpers
    def translate_type(type_str)
      dict = {
        'User' => 'gebruiker',
        'Document' => 'document',
        'Project' => 'project',
        'Discussion' => 'discussie',
        'Post' => 'discussie reactie',
        'AgendaItem' => 'agendapunt'
      }
      return dict[type_str] if dict[type_str]
      if Merb::Config[:environment] == 'development'  # this just makes catching misses a lot easier
        open 'log/translation_misses.txt', 'a' do |f|
          f << "A resource of type '#{type_Str}' was not found in translate_type.\n"
        end
      end
      type_str
    end

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

    def render_relative_date(date)
      date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
      days = (date - Date.today).to_i

      return 'vandaag' if days >= 0 and days < 1
      return 'morgen' if days >= 1 and days < 2
      return 'gisteren' if days >= -1 and days < 0

      return "over #{days} dagen" if days.abs < 60 and days > 0
      return "#{days.abs} dagen geleden" if days.abs < 60 and days < 0

      return short_human_date(date) # if days.abs < 182
      #return date.strftime('%A, %B %e, %Y')
    end

    def short_human_date(date)
      date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
      return "#{date.day} #{%w{0 Jan Feb Mar Apr Mei Jun Jul Aug Sep Okt Nov Dec}[date.month]} '#{date.year.to_s[2..3]}"
    end

    def format_notification(dictionary)
      if session[:notification]
        msg = ''
        if dictionary[session[:notification]]
          msg = dictionary[session[:notification]]
        else
          msg = 'Onvertaalde foutmelding: <strong>' + session[:notification].to_s + '</strong>'
        end
        session[:notification] = nil  # reset in the session
        return '<div class="notification">' + msg + '</div>'
      else
        return ''
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

    def translate_error_message(obj, msg_sym)
      dict = {
        'User' => {
        },
        'Document' => {
        },
      }
      return (dict[obj.class.to_s][msg_sym] or msg_sym.to_s) if dict[obj.class.to_s]
      if Merb::Config[:environment] == 'development'  # this just makes catching misses a lot easier
        open 'log/translation_misses.txt', 'a' do |f|
          f << "Symbol '#{msg_sym}', by #{obj.class.to_s}, was not found in translate_error_message.\n"
        end
      end
      msg_sym.to_s
    end

    def translate_notification_message(obj, msg_sym)
      dict = {
        'User' => {
        },
        'Document' => {
        },
      }
      return (dict[obj.class.to_s][msg_sym] or msg_sym.to_s) if dict[obj.class.to_s]
      if Merb::Config[:environment] == 'development'  # this just makes catching misses a lot easier
        open 'log/translation_misses.txt', 'a' do |f|
          f << "Symbol '#{msg_sym}', by #{obj.class.to_s}, was not found in translate_notification_message.\n"
        end
      end
      msg_sym.to_s
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
