require File.join(File.dirname(__FILE__), 'spec_helper')

describe "BirdiesAPI" do
  describe "update_tweets" do
    after(:each) do
      clean_db_storage
    end

    it "returns true if there are updates" do
      tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
      BirdiesBackend.update_tweets(tweets).should == "true"
      BirdiesBackend.update_tweets(tweets.to_s).should == 'false'
    end

  end

  describe "find_and_update from twitter" do
    context "API" do
      before(:all) do
        rm_db_storage
        file = File.open("#{FIXTURE_DIR}/query.json", "r")
        body = file.read
        stub_request(:get, "https://search.twitter.com/search.json?q=%23neo4j").
            with(:headers => {'Accept'=>'application/json'}).to_return(:status => 200, :body => body, :headers => {})
        BirdiesBackend.find_and_update('neo4j')
      end


      it "users returns a JSON" do
        BirdiesBackend.users.should == "[{\"name\":\"@phaneeshn\",\"link\":\"/user/phaneeshn\",\"value\":1},{\"name\":\"@gasi\",\"link\":\"/user/gasi\",\"value\":1},{\"name\":\"@jussihei\",\"link\":\"/user/jussihei\",\"value\":1},{\"name\":\"@russmiles\",\"link\":\"/user/russmiles\",\"value\":2},{\"name\":\"@philopator\",\"link\":\"/user/philopator\",\"value\":1},{\"name\":\"@iansrobinson\",\"link\":\"/user/iansrobinson\",\"value\":0},{\"name\":\"@edgarrd\",\"link\":\"/user/edgarrd\",\"value\":1},{\"name\":\"@mesirii\",\"link\":\"/user/mesirii\",\"value\":2},{\"name\":\"@paul_houle\",\"link\":\"/user/paul_houle\",\"value\":0},{\"name\":\"@nikolatankovic\",\"link\":\"/user/nikolatankovic\",\"value\":1},{\"name\":\"@rahulgchaudhary\",\"link\":\"/user/rahulgchaudhary\",\"value\":1},{\"name\":\"@nosqlweekly\",\"link\":\"/user/nosqlweekly\",\"value\":0},{\"name\":\"@bobbynorton\",\"link\":\"/user/bobbynorton\",\"value\":1},{\"name\":\"@neo4j\",\"link\":\"/user/neo4j\",\"value\":0},{\"name\":\"@sfrechette\",\"link\":\"/user/sfrechette\",\"value\":1},{\"name\":\"@peterneubauer\",\"link\":\"/user/peterneubauer\",\"value\":2}]"
      end


      it "tags returns a JSON" do
        BirdiesBackend.tags.should == "[{\"name\":\"#neo4j\",\"link\":\"/tag/neo4j\",\"value\":12},{\"name\":\"#aws\",\"link\":\"/tag/aws\",\"value\":1},{\"name\":\"#ec2\",\"link\":\"/tag/ec2\",\"value\":3},{\"name\":\"#graphdb\",\"link\":\"/tag/graphdb\",\"value\":7},{\"name\":\"#nosql\",\"link\":\"/tag/nosql\",\"value\":6},{\"name\":\"#gotocph\",\"link\":\"/tag/gotocph\",\"value\":4},{\"name\":\"#twitter\",\"link\":\"/tag/twitter\",\"value\":3},{\"name\":\"#couchdb\",\"link\":\"/tag/couchdb\",\"value\":1},{\"name\":\"#mongodb\",\"link\":\"/tag/mongodb\",\"value\":1},{\"name\":\"#hadoop\",\"link\":\"/tag/hadoop\",\"value\":1},{\"name\":\"#riak\",\"link\":\"/tag/riak\",\"value\":1},{\"name\":\"#redis\",\"link\":\"/tag/redis\",\"value\":1},{\"name\":\"#job\",\"link\":\"/tag/job\",\"value\":1},{\"name\":\"#thoughtworks\",\"link\":\"/tag/thoughtworks\",\"value\":1},{\"name\":\"#birdies\",\"link\":\"/tag/birdies\",\"value\":1}]"
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
        tweet.tags.each { |t| puts t }
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

      it "new users who has tweeted are keep in Tweeters" do
        peterneubauer = BirdiesBackend::User.find_by_twid('peterneubauer')
        BirdiesBackend::Tweeters.instance.users.should include(peterneubauer)
      end
    end
  end
#  describe "get " do
#    it "returns a JSON of all nodes"
#
#  end
end