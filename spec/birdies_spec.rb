require File.join(File.dirname(__FILE__), 'spec_helper')

describe "BirdiesAPI" do
  describe "calling update_tweets several times" do
    after(:each) do
      clean_db_storage
    end

    it "returns false if all items has been updated" do
      tweets = File.open("#{FIXTURE_DIR}/entry_1.json", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":true}'
      BirdiesBackend.update_tweets(tweets).should == '{"return":false}'
    end

    it "returns false if one item is not updated" do
      tweets = File.open("#{FIXTURE_DIR}/entry_1.json", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":true}'
      tweets = File.open("#{FIXTURE_DIR}/entry_2.json", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":true}'
      tweets = File.open("#{FIXTURE_DIR}/entry_1.json", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":false}'
    end

    it "returns false if all items has been updated" do
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":true}'
      BirdiesBackend.update_tweets(tweets.to_s).should == '{"return":false}'
    end

    it "returns true if one item is updated" do
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":true}'

    end
  end

  context "when graph is been populated with tweets" do
    before(:all) do
      rm_db_storage
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      BirdiesBackend.update_tweets(tweets).should == '{"return":true}'
    end

    context "API" do

      it "#user(twid) returns a JSON with all relationships" do
        BirdiesBackend.user('phaneeshn').should == %q({"twid"=>"phaneeshn", :tweeted=>[{"text"=>"Try #Neo4J with This Pre-Configured #AWS Machine http://www.readwriteweb.com/hack/2011/05/try-neo4j-with-this-pre-made-a.php", "link"=>"http://twitter.com/phaneeshn/statuses/68837206642536449", "date"=>Fri May 13 00:37:23 UTC 2011, "short"=>"Try  with This Pre-Configured  ", "tweet_id"=>"68837206642536449", :time_i=>1305247043}], :tags=>[{"text"=>"Try #Neo4J with This Pre-Configured #AWS Machine http://www.readwriteweb.com/hack/2011/05/try-neo4j-with-this-pre-made-a.php", "link"=>"http://twitter.com/phaneeshn/statuses/68837206642536449", "date"=>Fri May 13 00:37:23 UTC 2011, "short"=>"Try  with This Pre-Configured  ", "tweet_id"=>"68837206642536449"}]})
      end

      it "#users returns a list of all twids" do
        BirdiesBackend.users.should == "[{\"twid\":\"phaneeshn\",\"tweeted\":1},{\"twid\":\"gasi\",\"tweeted\":1},{\"twid\":\"jussihei\",\"tweeted\":1},{\"twid\":\"russmiles\",\"tweeted\":2},{\"twid\":\"philopator\",\"tweeted\":1},{\"twid\":\"iansrobinson\",\"tweeted\":0},{\"twid\":\"edgarrd\",\"tweeted\":1},{\"twid\":\"mesirii\",\"tweeted\":2},{\"twid\":\"paul_houle\",\"tweeted\":0},{\"twid\":\"nikolatankovic\",\"tweeted\":1},{\"twid\":\"rahulgchaudhary\",\"tweeted\":1},{\"twid\":\"nosqlweekly\",\"tweeted\":0},{\"twid\":\"bobbynorton\",\"tweeted\":1},{\"twid\":\"neo4j\",\"tweeted\":0},{\"twid\":\"sfrechette\",\"tweeted\":1},{\"twid\":\"peterneubauer\",\"tweeted\":2}]"
      end


      it "#tags returns a list of all tag names" do
        BirdiesBackend.tags.should == "[{\"name\":\"neo4j\",\"used_by_users\":27},{\"name\":\"aws\",\"used_by_users\":2},{\"name\":\"ec2\",\"used_by_users\":6},{\"name\":\"graphdb\",\"used_by_users\":15},{\"name\":\"nosql\",\"used_by_users\":12},{\"name\":\"gotocph\",\"used_by_users\":8},{\"name\":\"twitter\",\"used_by_users\":6},{\"name\":\"mongodb\",\"used_by_users\":2},{\"name\":\"hadoop\",\"used_by_users\":2},{\"name\":\"couchdb\",\"used_by_users\":2},{\"name\":\"job\",\"used_by_users\":2},{\"name\":\"riak\",\"used_by_users\":2},{\"name\":\"redis\",\"used_by_users\":2},{\"name\":\"thoughtworks\",\"used_by_users\":2},{\"name\":\"birdies\",\"used_by_users\":2}]"
#            "{\"names\":[\"neo4j\",\"aws\",\"ec2\",\"graphdb\",\"nosql\",\"gotocph\",\"twitter\",\"mongodb\",\"hadoop\",\"couchdb\",\"job\",\"riak\",\"redis\",\"thoughtworks\",\"birdies\"]}"
      end
    end

    context "Model" do
      it "creates tweets" do
        BirdiesBackend::Tweet.all.size.should == 15
      end

      it "creates users" do
        BirdiesBackend::User.all.each {|x| puts x}
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

        [ec2_tag, nosql_tag, neo4j_tag, graphdb_tag].each { |x| x.should_not be_nil }

        tweet.tags.size.should == 4
        tweet.tags.each { |t| puts t }
        tweet.tags.should include(nosql_tag, neo4j_tag, graphdb_tag, ec2_tag)
      end

      it "each tag is used_by_users some users" do
        tag = BirdiesBackend::Tag.all.first
        user = tag.used_by_users.first
        puts "USER #{user} tag: #{tag} has tags"
        user.tags.each {|t| puts "  #{t}"}
        user.tags.to_a.should include(tag)
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

      it "new users who has tweeted are keep in Tweeters" do
        peterneubauer = BirdiesBackend::User.find_by_twid('peterneubauer')
        BirdiesBackend::Tweeters.instance.users.should include(peterneubauer)
      end
    end
  end


end