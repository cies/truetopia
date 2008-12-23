require 'mediacloth/mediawikilexer'
require 'mediacloth/mediawikiparser'
require 'mediacloth/mediawikihtmlgenerator'

require 'test/unit'
require 'testhelper'

class HTMLGenerator_Test < Test::Unit::TestCase

    include TestHelper

    def test_input
        test_files("html") { |input,result,name|
            puts name
            parser = MediaWikiParser.new
            parser.lexer = MediaWikiLexer.new
            ast = parser.parse(input)
            MediaWikiParams.instance.time = Time.utc(2000, 1, 1, 1, 1, 1, 1)
            generator = MediaWikiHTMLGenerator.new
            generator.parse(ast)
            assert_equal generator.html, result, name
#             puts generator.html
        }
    end

end
