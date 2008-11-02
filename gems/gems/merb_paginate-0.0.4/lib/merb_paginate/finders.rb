require 'merb_paginate/core_ext'

# Load in the ORM Helpers as needed

if Object.const_defined? "DataMapper"
  require 'merb_paginate/finders/datamapper'
  # better than using Gem.loaded_specs as RubyGems is not required
  target = DataMapper.const_defined?('Base') ? 'Base' : 'Resource'
  DataMapper::const_get(target).class_eval { include MerbPaginate::Finders::Datamapper }
end

if Object.const_defined? "Sequel"
  require 'merb_paginate/finders/sequel'
  SequelModel::Base.class_eval { include MerbPaginate::Finders::Sequel }
end

if Object.const_defined? "ActiveRecord"
  require 'merb_paginate/finders/activerecord'
  ActiveRecord::Base.class_eval { include MerbPaginate::Finders::Activerecord }
end