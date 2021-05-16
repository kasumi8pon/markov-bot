require 'natto'
require './twitter_client'
require './markov'

class Bot
  def initialize(twitter_name)
    @nm = Natto::MeCab.new
    @markov = Markov.new
    @twitter_name = twitter_name
  end

  def load
    File.open("dics/#{@twitter_name}.dat", 'rb') do |f|
      @markov.load(f)
    end
  rescue
    puts 'No Dictionary'
  end

  def study
    texts = TwitterClient.new.all_tweets(@twitter_name)

    texts.each do |text|
      wakachi = @nm.enum_parse(text).map { |n| n.surface }
      wakachi.pop

      @markov.add_sentence(wakachi)
    end

    File.open("dics/#{@twitter_name}.dat", 'wb') do |f|
      @markov.save(f)
    end
  end

  def talk
    @markov.generate(nil)
  end
end
