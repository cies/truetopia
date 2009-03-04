# WARNING -- this class is not to be implemented in the first release

class Tag
  include DataMapper::Resource

  TAGGABLE_TYPES = %w{Document Project}

  property :taggable_id,    Integer, :key => true
  property :taggable_type,  Integer, :key => true
  property :name,           String,  :key => true, :length => 50
  property :created_at,     DateTime

  belongs_to :user

  # this is the way to create new tags, straight from the string..
  # maybe there for some methods should be made private
  # it returns an array (see the code), so the controller can take care of the error handling
  def self.create_tags_for(obj, tag_string)
    raise 'Only works for taggable types' unless Tag.taggable_types.includes? obj.class.to_s
    tag_strings = tags_string.split ','
    errors = []
    tag_strings.each do |str|
      str.strip!
      str.downcase!
      match = str.match /[a-z0-9_]*/
      unless match and m[0] == str  # check if there was a match and is the full tag was matched
        errors << str
        str.gsub!(/[^a-z0-9_]/, '_')  # sanitize the tag with underscores
      end
    end
    if errors.empty?
      # first destroy all the tags that exist for this object (if any)
      Tag.all(:taggable_id => obj.id, :taggable_type => obj.class.to_s) do |tag|
        tag.destroy
      end
      tag_strings.each do |str|
        tag = Tag.new(:taggable_id => obj.id, :taggable_type => obj.class.to_s, :name => str)
        tag.save
        # the most likely (assumed only) reason for the tag not to save is that it allready exists..
        # ..and it is ok for tags to allready exists, so no further error handling needed *cough*
      end
      return [:success, tag_strings]
    else
      return [errors, tag_strings]  # return the tags as they have been sanitised
    end
  end

  def self.name_count_for(name)
    Tag.count(:name => name)
  end

  def self.subscribable_types
    TAGGABLE_TYPES
  end
end