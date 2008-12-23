require 'singleton'

#MediaWiki parser parameter handler object.
#
#Stores and gives access to various parser settings and
#parser environment variables.
class MediaWikiParams

    #MediaWikiParams is a signleton class
    include Singleton

    #The name of the wiki page author
    attr_accessor :author

    def initialize
        @author = "Creator"
    end

    #Creation time of the page. Use overrideTime method to override
    #the value (useful for testing purposes).
    def time
        if @time
            return @time
        else
            return Time.now
        end
    end

    def time=(t)
        @time = t
    end

end
