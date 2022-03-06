require 'discordrb'

require_relative 'config'

bot = Discordrb::Bot.new token: BOT_CONFIG[:token]

bot.message do |e|
  puts "Received message, content: #{e.message.content}"
end

bot.run