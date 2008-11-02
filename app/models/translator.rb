
## This class should contain all the GUI string (in Dutch at the moment) that are present in the models
## In the future i hope to find a solution using the views but for now it doesn't matter too much.

class Translator
  def self.translate_event_message(obj, msg_sym)
    dict = {
      'User' => {
        :user_created => "Gebruiker [[/gebruiker/#{obj.login}]] aangemaakt.",
        :user_updated => "[[/gebruiker/#{obj.login}]] heeft zijn gegevens angepast.",
        },
      'Document' => {
        },
    }
    return (dict[obj.class.to_s][msg_sym] or msg_sym.to_s) if dict[obj.class.to_s]
    if Merb::Config[:environment] == 'development'  # this just makes catching misses a lot easier
      open 'log/translation_misses.txt', 'a' do |f|
        f << "Symbol '#{msg_sym}', by #{obj.class.to_s}, was not found in translate_event_message (Translator model).\n"
      end
    end
    msg_sym.to_s
  end
end