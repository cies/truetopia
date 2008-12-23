require 'mediacloth/mediawikilexer'
require 'test/unit'
require 'testhelper'

class Lexer_Test < Test::Unit::TestCase

    include TestHelper

    def test_standard_formatted_input
        test_files("lex") { |input,result,resultname|
            lexer = MediaWikiLexer.new
            tokens = lexer.tokenize(input)
            assert_equal(result, tokens.to_s, "Mismatch in #{resultname}")
        }
    end
    
    def test_internet_formatted_input
        test_files("lex") { |input,result,resultname|
            lexer = MediaWikiLexer.new
            tokens = lexer.tokenize(input.gsub("\n", "\r\n"))
            assert_equal(result.gsub("\n", "\r\n"), tokens.to_s, "Mismatch in #{resultname}")
        }
    end

    def test_paragraphs
        assert_equal(lex("text\n\ntext"),
            [[:PARA_START, ""], [:TEXT, "text"], [:PARA_END, "\n\n"], 
              [:PARA_START, ""], [:TEXT, "text"], [:PARA_END, ""], [false,false]])
        assert_equal(lex("text\r\n\r\ntext"),
            [[:PARA_START, ""], [:TEXT, "text"], [:PARA_END, "\r\n\r\n"], 
              [:PARA_START, ""], [:TEXT, "text"], [:PARA_END, ""], [false,false]])
        assert_equal(lex("Before\n\n=Headline="),
            [[:PARA_START, ""], [:TEXT, "Before"], [:PARA_END, "\n\n"],
             [:SECTION_START, "="], [:TEXT, "Headline"], [:SECTION_END, "="], [false,false]])
        assert_equal(lex("Before\r\n\r\n=Headline="),
            [[:PARA_START, ""], [:TEXT, "Before"], [:PARA_END, "\r\n\r\n"],
             [:SECTION_START, "="], [:TEXT, "Headline"], [:SECTION_END, "="], [false,false]])
    end

    def test_empty
        assert_equal(lex(""), [[false,false]])
    end

    def test_preformatted
        #assure preformatted text works as expected at the start of the text
        assert_equal(lex(" Foo\n"), [[:PRE, "Foo\n"], [false, false]])
        assert_equal(lex(" Foo\r\n"), [[:PRE, "Foo\r\n"], [false, false]])
        assert_equal(lex(" Foo"), [[:PRE, "Foo"], [false, false]])
    end

    def test_hline
        #assure that at the start of the text hline still works
        assert_equal(lex("----"), [[:HLINE, "----"], [false, false]])
        assert_equal(lex("\n----"), [[:HLINE, "----"], [false, false]])
        assert_equal(lex("\r\n----"), [[:HLINE, "----"], [false, false]])
    end
    
    def test_inline_links
        #assure that links in-line work 
        assert_equal(lex("http://example.com"), [[:PARA_START, ""], [:LINKSTART, ""], [:TEXT, "http://example.com"], [:LINKEND, "]"], [:PARA_END, ""], [false, false]])
        assert_equal(lex("http://example.com\n"), [[:PARA_START, ""], [:LINKSTART, ""], [:TEXT, "http://example.com"], [:LINKEND, "]"], [:PARA_END, ""], [false, false]])
        #assert_equal(lex("http://example.com''italic''"), [[:PARA_START, ""], [:LINKSTART, ""], [:TEXT, "http://example.com"], [:LINKEND, "]"], [:PARA_END, ""], [false, false]])
     end

    def test_ending_text_token
        #check for a problem when the last token is TEXT and it's not included
        assert_equal(lex("\n----\nfoo\n"),
            [[:HLINE, "----"], [:PARA_START, ""],
                [:TEXT, "\nfoo\n"], [:PARA_END, ""], [false, false]])
        assert_equal(lex("\r\n----\r\nfoo\r\n"),
            [[:HLINE, "----"], [:PARA_START, ""],
                [:TEXT, "\r\nfoo\r\n"], [:PARA_END, ""], [false, false]])
        assert_equal(lex("\n----\nfoo\n Hehe"),
            [[:HLINE, "----"], [:PARA_START, ""], [:TEXT, "\nfoo\n"],
                [:PARA_END, ""], [:PRE, "Hehe"], [false, false]])
        assert_equal(lex("\r\n----\r\nfoo\r\n Hehe"),
            [[:HLINE, "----"], [:PARA_START, ""], [:TEXT, "\r\nfoo\r\n"],
                [:PARA_END, ""], [:PRE, "Hehe"], [false, false]])
    end

    def test_bullets
        assert_equal(lex("* Foo"),
            [[:UL_START, ""], [:LI_START, ""], [:TEXT, "Foo"], [:LI_END, ""], [:UL_END, ""], [false, false]])
    end

    def test_nested_bullets
        assert_equal(lex("**Foo"), [[:UL_START, ""], [:LI_START, ""],
            [:UL_START, ""], [:LI_START, ""], [:TEXT, "Foo"], [:LI_END, ""],
            [:UL_END, ""], [:LI_END, ""], [:UL_END, ""], [false, false]])
    end

    def test_bullets_at_eof
        assert_equal(lex("* Foo\n*"),
            [[:UL_START, nil], [:LI_START, ""], [:TEXT, "Foo\n"], [:LI_END, ""], [:LI_START, ""], [:LI_END, ""], [:UL_END, ""], [false, false]])
    end

private
    def lex(string)
        lexer = MediaWikiLexer.new
        lexer.tokenize(string)
    end

end
