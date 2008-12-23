# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mediacloth}
  s.version = "0.0.3"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Pluron Inc."]
  s.autorequire = %q{mediacloth}
  s.cert_chain = nil
  s.date = %q{2007-10-31}
  s.email = %q{support@pluron.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/mediacloth", "lib/mediacloth.rb", "lib/mediacloth/mediawikihtmlgenerator.rb", "lib/mediacloth/mediawikilexer.rb~", "lib/mediacloth/mediawikiparams.rb", "lib/mediacloth/mediawikiwalker.rb", "lib/mediacloth/mediawikiparser.rb", "lib/mediacloth/mediawikiparser.y~", "lib/mediacloth/mediawikiparser.y", "lib/mediacloth/mediawikilexer.rb", "lib/mediacloth/mediawikiast.rb", "test/data", "test/parser.rb", "test/testhelper.rb", "test/lexer.rb", "test/debugwalker.rb", "test/dataproducers", "test/htmlgenerator.rb", "test/data/lex1", "test/data/lex2", "test/data/lex3", "test/data/lex4", "test/data/lex5", "test/data/lex6", "test/data/lex7", "test/data/lex8", "test/data/lex9", "test/data/result1", "test/data/html1", "test/data/html2", "test/data/html3", "test/data/html4", "test/data/html5", "test/data/html6", "test/data/html7", "test/data/html8", "test/data/html9", "test/data/lex10", "test/data/html10", "test/data/input1", "test/data/input2", "test/data/input3", "test/data/input4", "test/data/input5", "test/data/input6", "test/data/input7", "test/data/input8", "test/data/input9", "test/data/input10", "test/dataproducers/html.rb~", "test/dataproducers/lex.rb~", "test/dataproducers/lex.rb", "test/dataproducers/html.rb", "README"]
  s.has_rdoc = true
  s.homepage = %q{http://mediacloth.rubyforge.org/}
  s.rdoc_options = ["--title", "MediaCloth", "--main", "README"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A MediaWiki syntax parser and HTML generator.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
