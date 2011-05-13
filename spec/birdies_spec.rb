require File.join(File.dirname(__FILE__), 'spec_helper')

describe "BirdiesAPI" do
  describe "update from twitter" do
    before(:all) do
      file = File.open("#{FIXTURE_DIR}/query.json", "r")
      body = file.read
      stub_request(:get, "https://search.twitter.com/search.json?q=%23neo4j").
          with(:headers => {'Accept'=>'application/json'}).to_return(:status => 200, :body => body, :headers => {})
      BirdiesBackend.update('neo4j')
    end

    it "creates tweets" do
      BirdiesBackend::Tweet.all.size.should == 15
    end

    it "creates users" do
      BirdiesBackend::User.all.size.should == 16
    end

    it "tweets are always tweeted by a user" do
      tweet = BirdiesBackend::Tweet.find_by_tweet_id('68837206642536449')
      user = BirdiesBackend::User.find_by_twid('phaneeshn')
      tweet.tweeted_by.should == user
    end

    it "each tweet can have links" do
      tweet = BirdiesBackend::Tweet.find_by_tweet_id('68721628418281472')
      tweet.should_not be_nil
      link = BirdiesBackend::Link.find_by_url('http://twitpic.com/4wp696')
      link.should_not be_nil
      tweet.links.should include(link)
    end

    it "each tweet can have tags" do
      tweet = BirdiesBackend::Tweet.find_by_tweet_id('68766756432396288')
      #Using AWS Security Groups for #neo4j access control. http://t.co/xVYxHOd #ec2 #graphdb #nosql
      nosql_tag = BirdiesBackend::Tag.find_by_name('nosql')
      neo4j_tag = BirdiesBackend::Tag.find_by_name('neo4j')
      graphdb_tag = BirdiesBackend::Tag.find_by_name('graphdb')
      ec2_tag = BirdiesBackend::Tag.find_by_name('ec2')

      [ec2_tag, nosql_tag, neo4j_tag, graphdb_tag].each {|x| x.should_not be_nil}

      tweet.tags.size.should == 4
      puts "FOUND ----"
      tweet.tags.each {|t| puts t}
      tweet.tags.should include(nosql_tag, neo4j_tag, graphdb_tag, ec2_tag)
    end

    it "each tweet can mention other user" do
      #"id_str":"68836014914928640",
      #"text":"RT @jussihei: @gasi Thanks! AWS Security Groups can be used for #neo4j access control. http://bit.ly/iquUaB #ec2 #graphdb",
      tweet = BirdiesBackend::Tweet.find_by_tweet_id('68836014914928640')
      jussihei = BirdiesBackend::User.find_by_twid('jussihei')
      gasi = BirdiesBackend::User.find_by_twid('gasi')
      tweet.mentions.should include(jussihei, gasi)
      tweet.mentions.size.should == 2

      # these people should also, (just navigation the incoming relationship)
      jussihei.mentioned_from.should include(tweet)
    end
  end
#  describe "get " do
#    it "returns a JSON of all nodes"
#
#  end
end