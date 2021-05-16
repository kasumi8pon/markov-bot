require 'twitter'

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['consumer_key']
      config.consumer_secret     = ENV['consumer_secret']
    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    tweets = yield(max_id)
    collection += tweets.map { |tweet| tweet.full_text.gsub(/\R|http[\/\.\/\w:]*$/,"") }
    tweets.empty? ? collection.flatten : collect_with_max_id(collection, tweets.last.id - 1, &block)
  end

  def all_tweets(user)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: false}
      options[:max_id] = max_id unless max_id.nil?

      begin
        @client.user_timeline(user, options)
      rescue Twitter::Error::TooManyRequests => error
        sleep error.rate_limit.reset_in + 1
        retry
      end
    end
  end
end
