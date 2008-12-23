#AST Node
class AST
    attr_accessor :contents
    attr_accessor :parent
    attr_accessor :children

    def initialize
        @children = []
        @parent = nil
        @contents = ""
    end
end

#The root node for all wiki parse trees
class WikiAST < AST

end

#The node to represent paragraph with text inside
class ParagraphAST < AST
end

#The node to represent a simple or formatted text
#with more AST nodes inside.
class FormattedAST < AST
    #Currently recognized formatting: :Bold, :Italic, :Link, :InternalLink, :HLine
    attr_accessor :formatting
end

#The node to represent a simple or formatted text
class TextAST < FormattedAST
    #Currently recognized formatting: :Link, :InternalLink, :HLine
end

#The node to represent a simple Mediawiki link.
class LinkAST < AST
    #The link's URL
    attr_accessor :url
end

#The node to represent a Mediawiki internal link
class InternalLinkAST < AST
    #Holds the link locator, which is composed of a resource name only (e.g. the
    #name of a wiki page)
    attr_accessor :locator
end

#The node to represent a MediaWiki resource reference (embedded images, videos,
#etc.)
class ResourceLinkAST < AST
    #The resource prefix that indicates the type of resource (e.g. an image
    #resource is prefixed by "Image")
    attr_accessor :prefix
    #The resource locator
    attr_accessor :locator
end

class InternalLinkItemAST < AST
end

#The node to represent a table
class TableAST < AST
    attr_accessor :options
end

#The node to represent a table
class TableRowAST < AST
    attr_accessor :options
end

#The node to represent a table
class TableCellAST < AST
    #the type of cell, :head or :body
    attr_accessor :type
end

#The node to represent a list
class ListAST < AST
    #Currently recognized types: :Bulleted, :Numbered
    attr_accessor :list_type
end

#The node to represent a list item
class ListItemAST < AST
end

#The node to represent a section
class SectionAST < AST
    #The level of the section (1,2,3...) that would correspond to
    #<h1>, <h2>, <h3>, etc.
    attr_accessor :level
end

#The node to represent a preformatted contents
class PreformattedAST < AST
end
