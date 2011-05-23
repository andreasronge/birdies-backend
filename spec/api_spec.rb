require File.join(File.dirname(__FILE__), 'spec_helper')
describe "API" do
  before(:all) do
    rm_db_storage
  end

  it "should expand" do

    tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read

    #BirdiesBackend::API.should_receive(:eval).once.with("ASD")
    BirdiesBackend::API.stub(:eval) do |m|
      puts "GOT '#{m}'"
      eval(m)
    end
    BirdiesBackend::API.update_tweets(tweets)
  end
#  before(:all) do
#    rm_db_storage
#    puts "LOAD FILE"
#    tweets = File.open("#{FIXTURE_DIR}/tweets.txt", "r").read
#    BirdiesBackend.update_tweets(tweets).should == '{"changed":true}'
#  end

end
