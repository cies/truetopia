#The parser for the MediaWiki language.
#
#Usage together with a lexer:
# inputFile = File.new("data/input1", "r")
# input = inputFile.read
# parser = MediaWikiParser.new
# parser.lexer = MediaWikiLexer.new
# parser.parse(input)
class MediaWikiParser

token BOLDSTART BOLDEND ITALICSTART ITALICEND LINKSTART LINKEND LINKSEP
    INTLINKSTART INTLINKEND INTLINKSEP RESOURCE_SEP
    SECTION_START SECTION_END TEXT PRE
    HLINE SIGNATURE_NAME SIGNATURE_DATE SIGNATURE_FULL
    UL_START UL_END LI_START LI_END OL_START OL_END
    TABLE_START TABLE_END ROW_START ROW_END HEAD_START HEAD_END CELL_START CELL_END
    PARA_START PARA_END


rule

wiki:
    repeated_contents
        {
            @nodes.push WikiAST.new
            #@nodes.last.children.insert(0, val[0])
            #puts val[0]
            @nodes.last.children += val[0]
        }
    ;

contents:
      text
        {
            result = val[0]
        }
    | bulleted_list
        {
            result = val[0]
        }
    | numbered_list
        {
            result = val[0]
        }
    | preformatted
        {
            p = PreformattedAST.new
            p.contents = val[0]
            result = p
        }
    | section
        {
            result = val[0]
        }
    | PARA_START para_contents PARA_END
        {
            if val[1]
                p = ParagraphAST.new
                p.children = val[1]
                result = p
            end
        }
    | LINKSTART link_contents LINKEND
        {
            l = LinkAST.new
            l.url = val[1][0]
            l.children += val[1][1..-1] if val[1].length > 1
            result = l
        }
    | INTLINKSTART TEXT RESOURCE_SEP TEXT reslink_repeated_contents INTLINKEND
        {
            l = ResourceLinkAST.new
            l.prefix = val[1]
            l.locator = val[3]
            l.children = val[4] unless val[4].nil? or val[4].empty?
            result = l
        }
    | INTLINKSTART TEXT intlink_repeated_contents INTLINKEND
        {
            l = InternalLinkAST.new
            l.locator = val[1]
            l.children = val[2] unless val[2].nil? or val[2].empty?
            result = l
        }
    | table
    ;

#TODO: remove empty paragraphs in lexer
para_contents: 
        {
            result = nil
        }
    | repeated_contents
        {
            result = val[0]
        }
    ;

link_contents:
      TEXT
        {
            result = val
        }
    | TEXT LINKSEP link_repeated_contents
        {
            result = [val[0]]
            result += val[2]
        }
    ;


link_repeated_contents:
      repeated_contents
        {
            result = val[0]
        }
    | repeated_contents LINKSEP link_repeated_contents
        {
            result = val[0]
            result += val[2] if val[2]
        }
    ;


intlink_repeated_contents:
        {
            result = nil
        }
    | INTLINKSEP repeated_contents
        {
            result = val[1]
        }
    ;

reslink_repeated_contents:
        {
            result = nil
        }
    | INTLINKSEP reslink_repeated_contents
        {
            result = val[1]
        }
    | INTLINKSEP repeated_contents reslink_repeated_contents
        {
            i = InternalLinkItemAST.new
            i.children = val[1]
            result = [i]
            result += val[2] if val[2]
        }
    ;

repeated_contents: contents
        {
            result = []
            result << val[0]
        }
    | repeated_contents contents
        {
            result = []
            result += val[0]
            result << val[1]
        }
    ;

text: element
        {
            p = TextAST.new
            p.formatting = val[0][0]
            p.contents = val[0][1]
            result = p
        }
    | formatted_element
        {
            result = val[0]
        }
    ;

table:
      TABLE_START table_contents TABLE_END
        {
            table = TableAST.new
            table.children = val[1] unless val[1].nil? or val[1].empty?
            result = table
        }
    | TABLE_START TEXT table_contents TABLE_END
        {
            table = TableAST.new
            table.options = val[1]
            table.children = val[2] unless val[2].nil? or val[2].empty?
            result = table
        }

table_contents:
        {
            result = nil
        }
    | ROW_START row_contents ROW_END table_contents
        {
            row = TableRowAST.new
            row.children = val[1] unless val[1].nil? or val[1].empty?
            result = [row]
            result += val[3] unless val[3].nil? or val[3].empty?
        }
    | ROW_START TEXT row_contents ROW_END table_contents
        {
            row = TableRowAST.new
            row.children = val[2] unless val[2].nil? or val[2].empty?
            row.options = val[1]
            result = [row]
            result += val[4] unless val[4].nil? or val[4].empty?
        }

row_contents:
        {
            result = nil
        }
    | HEAD_START HEAD_END row_contents
        {
            cell = TableCellAST.new
            cell.type = :head
            result = [cell]
            result += val[2] unless val[2].nil? or val[2].empty?
        }
    | HEAD_START repeated_contents HEAD_END row_contents
        {
            cell = TableCellAST.new
            cell.children = val[1] unless val[1].nil? or val[1].empty?
            cell.type = :head
            result = [cell]
            result += val[3] unless val[3].nil? or val[3].empty?
        }
    | CELL_START CELL_END row_contents
        {
            cell = TableCellAST.new
            cell.type = :body
            result = [cell]
            result += val[2] unless val[2].nil? or val[2].empty?
        }
    | CELL_START repeated_contents CELL_END row_contents
        {
            cell = TableCellAST.new
            cell.children = val[1] unless val[1].nil? or val[1].empty?
            cell.type = :body
            result = [cell]
            result += val[3] unless val[3].nil? or val[3].empty?
        }
    

element:
      TEXT
        { return [:None, val[0]] }
    | HLINE
        { return [:HLine, val[0]] }
    | SIGNATURE_DATE
        { return [:SignatureDate, val[0]] }
    | SIGNATURE_NAME
        { return [:SignatureName, val[0]] }
    | SIGNATURE_FULL
        { return [:SignatureFull, val[0]] }
    ;

formatted_element: 
      BOLDSTART BOLDEND
        {
            result = FormattedAST.new
            result.formatting = :Bold
            result
        } 
    | ITALICSTART ITALICEND
        {
            result = FormattedAST.new
            result.formatting = :Italic
            result
        }
    | BOLDSTART repeated_contents BOLDEND
        {
            p = FormattedAST.new
            p.formatting = :Bold
            p.children += val[1]
            result = p
        }
    | ITALICSTART repeated_contents ITALICEND
        {
            p = FormattedAST.new
            p.formatting = :Italic
            p.children += val[1]
            result = p
        }
    ;

bulleted_list: UL_START list_item list_contents UL_END
        {
            list = ListAST.new
            list.list_type = :Bulleted
            list.children << val[1]
            list.children += val[2]
            result = list
        }
    ;

numbered_list: OL_START list_item list_contents OL_END
        {
            list = ListAST.new
            list.list_type = :Numbered
            list.children << val[1]
            list.children += val[2]
            result = list
        }
    ;

list_contents:
        { result = [] }
    list_item list_contents
        {
            result << val[1]
            result += val[2]
        }
    |
        { result = [] }
    ;

list_item: 
      LI_START LI_END
        {
            result = ListItemAST.new
        }
    | LI_START repeated_contents LI_END
        {
            li = ListItemAST.new
            li.children += val[1]
            result = li
        }
    ;

preformatted: PRE
        { result = val[0] }
    ;

section: SECTION_START repeated_contents SECTION_END
        { result = [val[1], val[0].length] 
            s = SectionAST.new
            s.children = val[1]
            s.level = val[0].length
            result = s
        }
    ;

end

---- header ----
require 'mediacloth/mediawikiast'

---- inner ----

attr_accessor :lexer

def initialize
    @nodes = []
    super
end

#Tokenizes input string and parses it.
def parse(input)
    @yydebug=true
    lexer.tokenize(input)
    do_parse
    return @nodes.last
end

#Asks the lexer to return the next token.
def next_token
    return @lexer.lex
end
