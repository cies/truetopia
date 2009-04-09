class Plan
  include DataMapper::Resource

  property :id,                     Serial
  property :number,                 Integer  # starts as nil
  property :created_at,             DateTime
  property :step1_document_version, Integer, :nullable => false
  property :step2_document_version, Integer, :nullable => false
  property :step3_document_version, Integer, :nullable => false

  belongs_to :project
  belongs_to :step1_document
  belongs_to :step2_document
  belongs_to :step3_document

  validates_present :project, :step1_document, :step2_document, :step3_document
  # has_unique_documents?
end