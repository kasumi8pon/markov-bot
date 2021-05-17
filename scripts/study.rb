require './bot'

bot = Bot.new(ARGV[0])
bot.study

puts 'Finished'
