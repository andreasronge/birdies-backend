module BirdiesBackend
  class User < Neo4j::Rails::Model

    # bio

    #Users incoming(:USER) # only for 1st level users (who tweeted themselves)

    property :twid
    index :twid

    has_n :tweeted
    has_n :follows
    has_n :knows
    has_n :tags  #used
    has_n :used # which tags user has used

    has_n(:mentioned_from).from(:mentions)  # from tweets

    def to_s
      "User #{twid}"
    end

    def self.create_or_find_by_twid(twid)
      twid.downcase!
      user = User.find_by_twid(twid)
      user ||= User.create!(:twid => twid)
      user
    end
  end
end

#<#Hashie::Rash created_at="Wed, 04 May 2011 12:31:46 +0000" from_user="jessicakilbride" from_user_id=280017273 from_user_id_str="280017273" geo=nil id=65755494752583680 id_str="65755494752583680" iso_language_code="de" metadata=<#Hashie::Rash result_type="recent"> profile_image_url="http://a2.twimg.com/profile_images/1331420611/image_normal.jpg" source="&lt;a href=&quot;http://twitter.com/#!/download/iphone&quot; rel=&quot;nofollow&quot;&gt;Twitter for iPhone&lt;/a&gt;" text="@justinbieber marry me?" to_user="justinbieber" to_user_id=8994366 to_user_id_str="8994366">
# => "<#Hashie::Rash created_at=\"Wed, 04 May 2011 15:58:36 +0000\" from_user=\"christianphang\" from_user_id=3398193 from_user_id_str=\"3398193\" geo=nil id=65807547021524992 id_str=\"65807547021524992\" iso_language_code=\"eo\" metadata=<#Hashie::Rash result_type=\"recent\"> profile_image_url=\"http://a0.twimg.com/profile_images/286951481/cartman-screw-you-guys_normal.jpg\" source=\"&lt;a href=&quot;http://ubersocial.com&quot; rel=&quot;nofollow&quot;&gt;\\303\\234berSocial&lt;/a&gt;\" text=\"Multi Platform: .NET(C#,F#,IronRuby,...) VS JVM(Java,Clojure,JRuby,...) #jaxcon\" to_user_id=nil to_user_id_str=nil>"
# ["from_user_id_str", "profile_image_url", "created_at", "from_user", "id_str", "metadata", "to_user_id", "text", "id", "from_user_id", "geo", "iso_language_code", "to_user_id_str", "source"]
# search.hashtag("jaxcon").result_type("recent").per_page(15).collect
# search.containing("marry me").to("justinbieber").result_type("recent").per_page(3).each
