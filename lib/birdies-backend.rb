require 'neo4j'
require 'twitter'

require 'birdies-backend/version'
require 'birdies-backend/link'
require 'birdies-backend/tag'
require 'birdies-backend/tweet'
require 'birdies-backend/user'
require 'birdies-backend/tweeters'
require 'birdies-backend/api'

module BirdiesBackend

  module ClassMethods

    def user(twid)
      user = User.find_by_twid(twid)
      ret = user.attributes.clone
      ret.merge!(:tweeted => user.tweeted.collect{|t| t.attributes.merge({:time_i => t.date.to_i})})
      ret.merge!(:tags => user.tweeted.collect{|t| t.attributes})
      ret
    end

    def users
      Tweeters.instance.users.collect { |u| {:twid => u.twid, :tweeted => u.tweeted.size }}.to_json
    end


    def tags
      #@birds.tags.collect{ |t| { :name => "#"+t.name, :link => "/tag/#{t.name}", :value => t.incoming(:TAGGED).size } }.to_json
      Tag.all.collect { |t| {:name => t.name, :used_by_users => t.used_by_users.size }}.to_json
    end

    # Returns JSON text {'changed': true/false}
    # If any of the tweets was updated then it will return true
    # If none of the tweets was updated it will return false
    def update_tweets(tweet_json)
        items = JSON.parse(tweet_json)
        # since we run all this in one transaction we have to remember which user, tags, links we have already created
        puts "-----------------------------------UPDATE TWEETS !"
        tweets =  {}; users = {}; tags = {}
        Neo4j::Transaction.run do
          changed = items.all? { |item| !Tweet.find_by_tweet_id(item['id_str']) && update_tweet(item, tweets, users, tags) }
          {:return => !!changed}.to_json
        end
    end

    def update_tweet(item, users, links, tags)
      tweet = Tweet.create_from_twitter_item(item)
      twid = item['from_user'].downcase
      user = users[twid] ||= User.create_or_find_by_twid(twid)
      user.tweeted << tweet
      user.save

      tweet.text.gsub(/(@\w+|https?\S+|#\w+)/).each do |t|
        if t =~ /^@.+/
          t = t[1..-1].downcase
          other = users[t] ||= User.create_or_find_by_twid(t)
          user.knows << other unless t == twid || user.knows.include?(other)
          user.save
          tweet.mentions << other
        end

        if t =~ /https?:.+/
          link = links[t] ||= Link.create_or_find_by_url(t)
          tweet.links << link
        end

        if t =~ /#.+/
          t = t[1..-1].downcase
          tag = tags[t] ||= Tag.create_or_find_by_name(t)
          tweet.tags << tag
          user.tags << tag unless user.tags.include?(tag)
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
