module BirdiesBackend
  class Tag < Neo4j::Rails::Model
    property :name
    index :name
    has_n(:used_by).from(:used)  # from User

    def to_s
      "Tag #{name}"
    end

    def self.create_or_find_by_name(name)
      name.downcase!
      tag = Tag.find_by_name(name)
      tag ||= Tag.create!(:name => name)
      tag
    end
  end
end