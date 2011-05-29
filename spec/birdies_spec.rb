require File.join(File.dirname(__FILE__), 'spec_helper')

describe "BirdiesAPI" do
  describe "calling update_tweets several times" do
    after(:each) do
      clean_db_storage
    end

    it "returns false if all items has been updated" do
      tweets = File.open("#{FIXTURE_DIR}/entry_1.json", "r").read
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => true)
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => false)
    end

    it "returns false if one item is not updated" do
      tweets = File.open("#{FIXTURE_DIR}/entry_1.json", "r").read
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => true)
      tweets = File.open("#{FIXTURE_DIR}/entry_2.json", "r").read
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => true)
      tweets = File.open("#{FIXTURE_DIR}/entry_1.json", "r").read
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => false)
    end

    it "returns false if all items has been updated" do
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => true)
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => false)
    end

    it "returns true if one item is updated" do
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      BirdiesBackend.update_tweets(tweets).should return_json(:changed => true)
    end
  end

  context "when graph is been populated with tweets" do
    before(:all) do
      rm_db_storage
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      @updated_tweets = BirdiesBackend.update_tweets(tweets)
    end

    context "API" do

      it "#updated_tweets returns all the tweets that has been updated" do
        @updated_tweets.should == "{\"return\":{\"changed\":true,\"tweets\":[{\"text\":\"Try #Neo4J with This Pre-Configured #AWS Machine http://www.readwriteweb.com/hack/2011/05/try-neo4j-with-this-pre-made-a.php\",\"tweet_id\":\"68837206642536449\"},{\"text\":\"RT @jussihei: @gasi Thanks! AWS Security Groups can be used for #neo4j access control. http://bit.ly/iquUaB #ec2 #graphdb\",\"tweet_id\":\"68836014914928640\"},{\"text\":\"RT @jussihei: Using AWS Security Groups for #neo4j access control. http://t.co/xVYxHOd #ec2 #graphdb #nosql\",\"tweet_id\":\"68766756432396288\"},{\"text\":\"Using AWS Security Groups for #neo4j access control. http://t.co/xVYxHOd #ec2 #graphdb #nosql\",\"tweet_id\":\"68766654917648385\"},{\"text\":\"RT @iansrobinson: Friends don't let friends store graphs in relational databases. Depth 2 advice from #gotocph (#neo4j )\",\"tweet_id\":\"68764532641767425\"},{\"text\":\"RT @iansrobinson: Friends don't let friends store graphs in relational databases. Depth 2 advice from #gotocph (#neo4j )\",\"tweet_id\":\"68742380441972737\"},{\"text\":\"@paul_houle how big are your graphs? Where can I read more about them? The #neo4j #graphdb stores 32 bn nodes and rels and 64bn props/db Thx\",\"tweet_id\":\"68738346838536192\"},{\"text\":\"@nikolatankovic What trouble? I just clicked on the link in your tweet and it showed up? http://twitpic.com/4wp696 #twitter #neo4j #graphdb\",\"tweet_id\":\"68721628418281472\"},{\"text\":\"RT @nosqlweekly: NoSQL Weekly (Issue 24 - May 12, 2011) - http://eepurl.com/dM9Ww #nosql #couchdb #mongodb #hadoop #riak #redis #neo4j #job\",\"tweet_id\":\"68710884444340224\"},{\"text\":\"RT @neo4j: &quot;From ThoughtWorks to Neo Technology&quot; by our Director of Customer Success! @iansrobinson http://bit.ly/jS8UjM #neo4j #thoughtworks #graphdb\",\"tweet_id\":\"68705418318319616\"},{\"text\":\"World Wide Webber - Square Pegs and Round Holes in the NOSQL World http://stphf.me/txhE9\\n#nosql #neo4j\",\"tweet_id\":\"68704918034317312\"},{\"text\":\"@mesirii I'm having trouble accessing http://t.co/BM1CJAW #neo4j #nosql #graphdb #twitter\",\"tweet_id\":\"68703194410262528\"},{\"text\":\"#birdies starts to look nice, @mesirii ! http://birdies.heroku.com/ #neo4j #nosql #graphdb #twitter\",\"tweet_id\":\"68700452300128256\"},{\"text\":\"RT @iansrobinson: Friends don't let friends store graphs in relational databases. Depth 2 advice from #gotocph (#neo4j )\",\"tweet_id\":\"68699969984540673\"},{\"text\":\"RT @mesirii: Current tweets for #neo4j and #gotocph at http://birdies.heroku.com/tag/gotocph, more graph goodness planned (is using hosted neo4j-server)\",\"tweet_id\":\"68699715818110976\"}]}}"
      end

      it "#user(twid) returns a JSON with all relationships" do
        BirdiesBackend.user('phaneeshn').should == "{\"return\":{\"twid\":\"phaneeshn\",\"tweeted\":[{\"text\":\"Try #Neo4J with This Pre-Configured #AWS Machine http://www.readwriteweb.com/hack/2011/05/try-neo4j-with-this-pre-made-a.php\",\"link\":\"http://twitter.com/phaneeshn/statuses/68837206642536449\",\"date\":\"2011-05-13T00:37:23Z\",\"short\":\"Try  with This Pre-Configured  \",\"tweet_id\":\"68837206642536449\",\"time_i\":1305247043}],\"tags\":[{\"name\":\"neo4j\"},{\"name\":\"aws\"}],\"knows\":[]}}"
      end

      it "#tag(tagname) returns a JSON with all tags" do
        BirdiesBackend.tag('nosql').should == "{\"return\":{\"name\":\"nosql\",\"tweeted_by\":[{\"twid\":\"russmiles\"},{\"twid\":\"jussihei\"},{\"twid\":\"rahulgchaudhary\"},{\"twid\":\"sfrechette\"},{\"twid\":\"nikolatankovic\"},{\"twid\":\"peterneubauer\"}],\"tweets\":[{\"text\":\"RT @jussihei: Using AWS Security Groups for #neo4j access control. http://t.co/xVYxHOd #ec2 #graphdb #nosql\",\"link\":\"http://twitter.com/russmiles/statuses/68766756432396288\",\"date\":\"2011-05-12T19:57:27Z\",\"short\":\"RT : Using AWS Security Groups \",\"tweet_id\":\"68766756432396288\"},{\"text\":\"Using AWS Security Groups for #neo4j access control. http://t.co/xVYxHOd #ec2 #graphdb #nosql\",\"link\":\"http://twitter.com/jussihei/statuses/68766654917648385\",\"date\":\"2011-05-12T19:57:02Z\",\"short\":\"Using AWS Security Groups for  \",\"tweet_id\":\"68766654917648385\"},{\"text\":\"RT @nosqlweekly: NoSQL Weekly (Issue 24 - May 12, 2011) - http://eepurl.com/dM9Ww #nosql #couchdb #mongodb #hadoop #riak #redis #neo4j #job\",\"link\":\"http://twitter.com/rahulgchaudhary/statuses/68710884444340224\",\"date\":\"2011-05-12T16:15:26Z\",\"short\":\"RT : NoSQL Weekly (Issue 24 - M\",\"tweet_id\":\"68710884444340224\"},{\"text\":\"World Wide Webber - Square Pegs and Round Holes in the NOSQL World http://stphf.me/txhE9\\n#nosql #neo4j\",\"link\":\"http://twitter.com/sfrechette/statuses/68704918034317312\",\"date\":\"2011-05-12T15:51:43Z\",\"short\":\"World Wide Webber - Square Pegs\",\"tweet_id\":\"68704918034317312\"},{\"text\":\"@mesirii I'm having trouble accessing http://t.co/BM1CJAW #neo4j #nosql #graphdb #twitter\",\"link\":\"http://twitter.com/nikolatankovic/statuses/68703194410262528\",\"date\":\"2011-05-12T15:44:52Z\",\"short\":\" I'm having trouble accessing  \",\"tweet_id\":\"68703194410262528\"},{\"text\":\"#birdies starts to look nice, @mesirii ! http://birdies.heroku.com/ #neo4j #nosql #graphdb #twitter\",\"link\":\"http://twitter.com/peterneubauer/statuses/68700452300128256\",\"date\":\"2011-05-12T15:33:58Z\",\"short\":\" starts to look nice,  !     \",\"tweet_id\":\"68700452300128256\"}]}}"
      end

      it "#users returns a list of all twids" do
        BirdiesBackend.users.should == "{\"return\":[{\"twid\":\"phaneeshn\",\"tweeted\":1},{\"twid\":\"gasi\",\"tweeted\":1},{\"twid\":\"jussihei\",\"tweeted\":1},{\"twid\":\"russmiles\",\"tweeted\":2},{\"twid\":\"philopator\",\"tweeted\":1},{\"twid\":\"iansrobinson\",\"tweeted\":0},{\"twid\":\"edgarrd\",\"tweeted\":1},{\"twid\":\"mesirii\",\"tweeted\":2},{\"twid\":\"paul_houle\",\"tweeted\":0},{\"twid\":\"nikolatankovic\",\"tweeted\":1},{\"twid\":\"rahulgchaudhary\",\"tweeted\":1},{\"twid\":\"nosqlweekly\",\"tweeted\":0},{\"twid\":\"bobbynorton\",\"tweeted\":1},{\"twid\":\"neo4j\",\"tweeted\":0},{\"twid\":\"sfrechette\",\"tweeted\":1},{\"twid\":\"peterneubauer\",\"tweeted\":2}]}"
      end


      it "#tags returns a list of all tag names" do
        BirdiesBackend.tags.should == "{\"return\":[{\"name\":\"neo4j\",\"used_by_users\":12},{\"name\":\"aws\",\"used_by_users\":1},{\"name\":\"ec2\",\"used_by_users\":3},{\"name\":\"graphdb\",\"used_by_users\":7},{\"name\":\"nosql\",\"used_by_users\":6},{\"name\":\"gotocph\",\"used_by_users\":4},{\"name\":\"twitter\",\"used_by_users\":3},{\"name\":\"mongodb\",\"used_by_users\":1},{\"name\":\"hadoop\",\"used_by_users\":1},{\"name\":\"couchdb\",\"used_by_users\":1},{\"name\":\"job\",\"used_by_users\":1},{\"name\":\"riak\",\"used_by_users\":1},{\"name\":\"redis\",\"used_by_users\":1},{\"name\":\"thoughtworks\",\"used_by_users\":1},{\"name\":\"birdies\",\"used_by_users\":1}]}"
      end
    end

    context "Model" do
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

        [ec2_tag, nosql_tag, neo4j_tag, graphdb_tag].each { |x| x.should_not be_nil }

        tweet.tags.size.should == 4
        tweet.tags.should include(nosql_tag, neo4j_tag, graphdb_tag, ec2_tag)
      end

      it "each tag is used_by_users some users" do
        tag = BirdiesBackend::Tag.all.first
        user = tag.used_by_users.first
        user.used_tags.to_a.should include(tag)
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