require 'mediacloth/mediawikiast'

#Default walker to traverse the parse tree.
#
#The walker traverses the entire parse tree and does nothing.
#To implement some functionality during this process, reimplement
#<i>parse...</i> methods and don't forget to call super() to not
#break the walk.
#
#Current implementations: MediaWikiHTMLGenerator, DebugWalker
class MediaWikiWalker

    #Walks through the AST
    def parse(ast)
        parse_wiki_ast(ast)
    end

protected

#===== reimplement these methods and don't forget to call super() ====#

    #Reimplement this
    def parse_wiki_ast(ast)
        ast.children.map do |c|
            r = parse_formatted(c) if c.class == FormattedAST
            r = parse_text(c) if c.class == TextAST
            r = parse_list(c) if c.class == ListAST
            r = parse_preformatted(c) if c.class == PreformattedAST
            r = parse_section(c) if c.class == SectionAST
            r = parse_paragraph(c) if c.class == ParagraphAST
            r = parse_link(c) if c.class == LinkAST
            r = parse_internal_link(c) if c.class == InternalLinkAST
            r = parse_resource_link(c) if c.class == ResourceLinkAST
            r = parse_internal_link_item(c) if c.class == InternalLinkItemAST
            r = parse_table(c) if c.class == TableAST
            r = parse_table_row(c) if c.class == TableRowAST
            r = parse_table_cell(c) if c.class == TableCellAST
            r
        end
    end

    #Reimplement this
    def parse_paragraph(ast)
        parse_wiki_ast(ast)
    end

    #Reimplement this
    def parse_formatted(ast)
        parse_wiki_ast(ast)
    end

    #Reimplement this
    def parse_text(ast)
    end

    #Reimplement this
    def parse_list(ast)
        ast.children.map do |c|
            parse_list_item(c) if c.class == ListItemAST
        end
    end

    #Reimplement this
    def parse_list_item(ast)
        parse_wiki_ast(ast)
    end

    #Reimplement this
    def parse_preformatted(ast)
    end

    #Reimplement this
    def parse_section(ast)
        parse_wiki_ast(ast)
    end
    
    #Reimplement this
    def parse_link(ast)
        parse_wiki_ast(ast)
    end
    
    #Reimplement this
    def parse_internal_link(ast)
        ast.children.map do |c|
            parse_internal_link_item(c) if c.class == InternalLinkItemAST
        end
    end
     
    #Reimplement this
    def parse_resource_link(ast)
        ast.children.map do |c|
            parse_internal_link_item(c) if c.class == InternalLinkItemAST
        end
    end

    #Reimplement this
    def parse_internal_link_item(ast)
        parse_wiki_ast(ast)
    end

    #Reimplement this
    def parse_table(ast)
        parse_wiki_ast(ast)
    end

    #Reimplement this
    def parse_table_row(ast)
        parse_wiki_ast(ast)
    end

    #Reimplement this
    def parse_table_cell(ast)
        parse_wiki_ast(ast)
    end

end
