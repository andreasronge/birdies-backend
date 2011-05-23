module BirdiesBackend
  class Link < Neo4j::Rails::Model

    property :url
    index :url

    has_n(:tweets).from(:links)

    def self.create_or_find_by_url(url)
      Link.find_by_url(url) || Link.create!(:url => url)
    end
  end
end