module BirdiesBackend
  class Tweeters < Neo4j::Rails::Model
    has_n(:users) # user who has tweeted

    def self.instance
      @instance ||= create_or_find
    end

    def self.create_or_find
      Tweeters.all.first || Tweeters.create!
    end
  end
end
