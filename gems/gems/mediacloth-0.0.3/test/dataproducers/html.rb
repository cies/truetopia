require 'mediacloth/mediawikilexer'
require 'mediacloth/mediawikiparser'
require 'mediacloth/mediawikiparams'
require 'mediacloth/mediawikihtmlgenerator'

def produce(index)
    file = File.new("../test/data/html#{index}", "w")
    inputFile = File.new("../test/data/input#{index}", "r")
    input = inputFile.read

    parser = MediaWikiParser.new
    parser.lexer = MediaWikiLexer.new
    ast = parser.parse(input)
    MediaWikiParams.instance.time = Time.mktime(2000, 1, 1, 1, 1, 1, 1)
    generator = MediaWikiHTMLGenerator.new
    generator.parse(ast)

#    puts generator.html
    file.write(generator.html)
    file.close
end

# (3..5).each { |i| produce(i) }
produce(5)
