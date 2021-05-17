require './bot'

bot = Bot.new(ARGV[0])
bot.load

puts bot.talk
