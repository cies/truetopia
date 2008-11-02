Gem::Specification.new do |s|
  s.name = %q{merb-auth}
  s.version = "0.9.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Neighman"]
  s.date = %q{2008-10-30}
  s.description = %q{merb-auth.  The official authentication plugin for merb.  Setup for the default stack}
  s.email = %q{has.sox@gmail.com}
  s.files = ["LICENSE", "README.textile", "Rakefile", "TODO", "lib/merb-auth.rb"]
  s.homepage = %q{http://www.merbivore.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb-auth}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{merb-auth.  The official authentication plugin for merb.  Setup for the default stack}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<merb-core>, ["~> 0.9.12"])
      s.add_runtime_dependency(%q<merb-auth-core>, ["~> 0.9.12"])
      s.add_runtime_dependency(%q<merb-auth-more>, ["~> 0.9.12"])
      s.add_runtime_dependency(%q<merb-auth-slice-password>, ["~> 0.9.12"])
    else
      s.add_dependency(%q<merb-core>, ["~> 0.9.12"])
      s.add_dependency(%q<merb-auth-core>, ["~> 0.9.12"])
      s.add_dependency(%q<merb-auth-more>, ["~> 0.9.12"])
      s.add_dependency(%q<merb-auth-slice-password>, ["~> 0.9.12"])
    end
  else
    s.add_dependency(%q<merb-core>, ["~> 0.9.12"])
    s.add_dependency(%q<merb-auth-core>, ["~> 0.9.12"])
    s.add_dependency(%q<merb-auth-more>, ["~> 0.9.12"])
    s.add_dependency(%q<merb-auth-slice-password>, ["~> 0.9.12"])
  end
end
