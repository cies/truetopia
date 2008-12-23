require 'mediacloth/mediawikilexer'
require 'mediacloth/mediawikiparser'
require 'mediacloth/mediawikiast'
require 'mediacloth/mediawikiparams'
require 'mediacloth/mediawikiwalker'
require 'mediacloth/mediawikihtmlgenerator'

#Helper module to facilitate MediaCloth usage.
module MediaCloth

    #Parses wiki formatted +input+ and generates its html representation.
    def wiki_to_html(input)
        parser = MediaWikiParser.new
        parser.lexer = MediaWikiLexer.new
        ast = parser.parse(input)
        walker = MediaWikiHTMLGenerator.new
        walker.parse(ast)
        walker.html
    end

    module_function :wiki_to_html

end
