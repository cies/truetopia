require 'mediacloth/mediawikiwalker'

#A walker to build textual representation of the parse tree.
#
#Use as any other walker and then query for tree:
# parser = MediaWikiParser.new
# parser.lexer = MediaWikiLexer.new
# ast = parser.parse(input)
# walker = DebugWalker.new
# walker.parse(ast)
# puts walker.tree
class DebugWalker < MediaWikiWalker

    #The textual representation of the parse tree.
    attr_reader :tree

    def initialize
        super
        @tree = ""
    end

protected

    def parse_wiki_ast(ast)
        info(ast)
        super(ast)
    end

    def parse_paragraph(ast)
        info(ast)
        super(ast)
    end

    def parse_text(ast)
        info(ast, ast.formatting)
        super(ast)
    end

    def parse_list(ast)
        info(ast, ast.class)
        super(ast)
    end

    def parse_list_item(ast)
        info(ast)
        super(ast)
    end

    def parse_preformatted(ast)
        info(ast)
    end

    def parse_section(ast)
        info(ast)
    end

private
    #Pretty-print ast node information
    def info(ast, *args)
        @tree += "#{ast.class}"
        if args.length > 0
            @tree += ": "
            args.each { |arg| @tree += "#{arg} " }
        end
        @tree += "\n"
    end

end
