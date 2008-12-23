require 'mediacloth/mediawikilexer'
require 'mediacloth/mediawikiparser'

require 'test/unit'
require 'testhelper'
require 'debugwalker'

class Parser_Test < Test::Unit::TestCase

    include TestHelper

    def test_input
        test_files("result") { |input,result|
            parser = MediaWikiParser.new
            parser.lexer = MediaWikiLexer.new
            ast = parser.parse(input)
            walker = DebugWalker.new
            walker.parse(ast)
        }
    end

end
