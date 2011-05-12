module BirdiesBackend
  class Tweet < Neo4j::Rails::Model
    property :text
    property :link
    property :date
    property :short #first 30 chars w/o tokens
    property :tweet_id

    index :tweet_id

    has_n :tags
    has_n :mentions
    has_n :links
    has_n(:tweeted_by).from(:tweeted)


    def self.create_from_twitter_item(item)
      Tweet.create! do |t|
         t.tweet_id = item.id_str
         t.text =  item.text
         t.short = item.text.gsub(/(@\w+|https?\S+|#\w+)/,"")[0..30]
      end
    end
#
#   User incoming(:TWEETED)
#   has_n Tag outgoing(:TAGGED)
#   has_n User outgoing(:MENTIONS)
#   has_n Link outgoing(:LINKS)


  end

end