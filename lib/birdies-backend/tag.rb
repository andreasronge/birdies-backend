module BirdiesBackend
  class Tag < Neo4j::Rails::Model
    property :name
    index :name
    has_n(:used_by_users).from(:tags)  # from User

    def to_s
      "Tag #{name}"
    end

    def self.create_or_find_by_name(name)
      Tag.find_by_name(name) || Tag.create! do |tag|
        tag.name = name
      end
    end
  end
end