require 'neo4j'
require 'twitter'

require 'birdies-backend/version'
require 'birdies-backend/tweet'

module BirdiesBackend

  module ClassMethods
    def update(tags)
      search = Twitter::Search.new
      tags.each { |tag| search.hashtag(tag) }

      search.each do |item|
        puts "GOT tweet from #{item.from_user}"
        Tweet.create_from_twitter_item(item)
      end
#
#      result = []
#      all_new = true
#      while all_new
#        all_new = search.all? { |item| add_tweet(item) && result << item }
#        search.fetch_next_page
#      end
#      result
#
    end
  end

  extend ClassMethods
end



#  class Users
#   category #indexed (:category, :category)
#   incoming(:USERS) to root
#   has_n User outgoing(:USER)
#end
#
#class Tags
#	category #indexed (:category, :category)
#	incoming(:TAGS) to root
#    has_n User outgoing(:USER)
#end
#
#class User
#   twid #indexed( :tweets, :twid)
#   bio
#
#   Users incoming(:USER) # only for 1st level users (who tweeted themselves)
#
#   has_n Tweet outgoing(:TWEETED)
#   has_n User  outgoing(:FOLLOWS)
#   has_n User  outgoing(:KNOWS)
#   has_n Tag   outgoing(:USED)
#
#end
#
#class Tweet
#   text
#   link
#   date
#   short #first 30 chars w/o tokens
#   id #indexed(:tweets, :id)
#
#   User incoming(:TWEETED)
#   has_n Tag outgoing(:TAGGED)
#   has_n User outgoing(:MENTIONS)
#   has_n Link outgoing(:LINKS)
#end
#
#class Tag
#   name #indexed(:tags,:name)
#
#   Tags incoming(:TAGS)
#
#   has_n Tweet incoming(:TAGGED)
#   has_n User incoming(:USED)
#end
#
#class Link
#   url #indexed(:links, :url)
#
#   has_n Tweet incoming(:LINKS)
#end
