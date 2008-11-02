Gem::Specification.new do |s|
  s.name = %q{abstract}
  s.version = "1.0.0"

  s.specification_version = 1 if s.respond_to? :specification_version=

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["makoto kuwata"]
  s.cert_chain = nil
  s.date = %q{2006-03-12}
  s.description = %q{'abstract.rb' is a library which enable you to define abstract method in Ruby.}
  s.files = ["lib/abstract.rb", "test/test.rb", "README.txt", "ChangeLog", "setup.rb", "abstract.gemspec"]
  s.homepage = %q{http://rubyforge.org/projects/abstract}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{a library which enable you to define abstract method in Ruby}
  s.test_files = ["test/test.rb"]
end
