require 'neo4j'
require 'twitter'

require 'birdies-backend/version'
require 'birdies-backend/link'
require 'birdies-backend/tag'
require 'birdies-backend/tweet'
require 'birdies-backend/user'
require 'birdies-backend/tweeters'

module BirdiesBackend

  module ClassMethods

#    get '/users' do
#      content_type :json
#      @birds.users.collect{ |u| { :name => "@"+u.twid, :link => "/user/#{u.twid}", :value => u.outgoing(:TWEETED).size }}.to_json
#    end
    def users
      Tweeters.instance.users.collect { |u| {:name => "@"+u.twid, :link => "/user/#{u.twid}", :value => u.tweeted.size} }.to_json
    end


#    get '/tags' do
#      content_type :json
#      @birds.tags.collect{ |t| { :name => "#"+t.name, :link => "/tag/#{t.name}", :value => t.incoming(:TAGGED).size } }.to_json
#    end
    def tags
      Tag.all.collect { |t| {:name => "#"+t.name, :link => "/tag/#{t.name}", :value => t.used_by.size} }.to_json
    end


    def update_tweets(tweets)
      items = JSON.parse(tweets)
      Neo4j::Transaction.run do
        items.all? do |item|
          !Tweet.find_by_tweet_id(item['id_str']) && update_tweet(item)
        end.to_json
      end
    end

    def update_tweet(item)
      tweet = Tweet.create_from_twitter_item(item)
      twid = item['from_user']
      user = User.create_or_find_by_twid(twid)
      user.tweeted << tweet
      user.save

      tweet.text.gsub(/(@\w+|https?\S+|#\w+)/).each do |t|
        if t =~ /^@.+/
          t = t[1..-1].downcase
          other = User.create_or_find_by_twid(t)
          user.knows << other unless t == twid || user.knows.include?(other)
          user.save
          tweet.mentions << other
        end

        if t =~ /https?:.+/
          link = Link.create_or_find_by_url(t)
          tweet.links << link
        end

        if t =~ /#.+/
          t = t[1..-1].downcase
          tag = Tag.create_or_find_by_name(t)
          tweet.tags << tag
          user.used << tag unless user.used.include?(tag)
        end
      end

      user.save!
      tweet.save!
      true
    end

    # post '/update' do
    def find_and_update(tags)
      search = Twitter::Search.new
      tags.each { |tag| search.hashtag(tag) }

#      Neo4j::Transaction.run do
      search.each do |item|
        update_tweet(item)
        #       end
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
