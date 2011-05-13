module BirdiesBackend
  class Link < Neo4j::Rails::Model

    property :url
    index :url

    has_n(:tweets).from(:links)

    def self.create_or_find_by_url(url)
      link = Link.find_by_url(url)
      link ||= Link.create!(:url => url)
      link
    end
  end
end