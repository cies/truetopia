Gem::Specification.new do |s|
  s.name = %q{dm-migrations}
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Sadauskas"]
  s.date = %q{2008-10-12}
  s.description = %q{DataMapper plugin for writing and speccing migrations}
  s.email = ["psadauskas@gmail.com"]
  s.extra_rdoc_files = ["README.txt", "LICENSE", "TODO"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.txt", "Rakefile", "TODO", "db/migrations/1_create_people_table.rb", "db/migrations/2_add_dob_to_people.rb", "db/migrations/config.rb", "examples/sample_migration.rb", "examples/sample_migration_spec.rb", "lib/dm-migrations.rb", "lib/dm-migrations/version.rb", "lib/migration.rb", "lib/migration_runner.rb", "lib/spec/example/migration_example_group.rb", "lib/spec/matchers/migration_matchers.rb", "lib/sql.rb", "lib/sql/column.rb", "lib/sql/mysql.rb", "lib/sql/postgresql.rb", "lib/sql/sqlite3.rb", "lib/sql/table.rb", "lib/sql/table_creator.rb", "lib/sql/table_modifier.rb", "spec/integration/migration_runner_spec.rb", "spec/integration/migration_spec.rb", "spec/integration/sql_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/migration_spec.rb", "spec/unit/sql/column_spec.rb", "spec/unit/sql/postgresql_spec.rb", "spec/unit/sql/sqlite3_extensions_spec.rb", "spec/unit/sql/table_creator_spec.rb", "spec/unit/sql/table_modifier_spec.rb", "spec/unit/sql/table_spec.rb", "spec/unit/sql_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sam/dm-more/tree/master/dm-migrations}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{DataMapper plugin for writing and speccing migrations}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<dm-core>, ["> 0.9.5"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<dm-core>, ["> 0.9.5"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<dm-core>, ["> 0.9.5"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
