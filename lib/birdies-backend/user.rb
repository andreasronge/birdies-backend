module BirdiesBackend
  class User < Neo4j::Rails::Model

    property :twid
    index :twid

    has_n :tweeted
    has_n :follows
    has_n :knows
    has_n :tags

    has_n(:mentioned_from).from(:mentions) # from tweets

    def to_s
      "User #{twid}"
    end

    def self.create_or_find_by_twid(twid)
      User.find_by_twid(twid) || User.create! do |u|
        u.twid = twid
        Tweeters.instance.users << u
#          Tweeters.instance.save
      end
    end
  end
end

