require 'rubygems'
require 'bundler/setup'

require 'discordrb'

require_relative 'database'
require_relative 'config'

bot = Discordrb::Bot.new token: BOT_CONFIG[:token]
botdb = Scrap::Database.new({ dbname: 'realbot' })

MSGLOG_GET_ALL = %(select * from discord_log).freeze
bot.message(with_text: "c!markov") do |e|
  require 'marky_markov'
  markov = MarkyMarkov::TemporaryDictionary.new
  query = botdb.query(MSGLOG_GET_ALL) 
  query.each do |row|
    markov.parse_string row['mdata']
  end
  e.respond(markov.generate_1_sentences)
end

MSGLOG_NEW = %(insert into discord_log (cid, mid, uid, mtime, mdata) values ($1, $2, $3, $4, $5)).freeze
MSGLOG_EDIT = %(update discord_log set etime = $3, edata = $4 where cid = $1 and mid = $2).freeze
MSGLOG_DELETE = %(update discord_log set del = true where cid = $1 and mid = $2).freeze

bot.message do |e|
  if e.message.content != "c!markov"
    botdb.query(MSGLOG_NEW, [
      e.channel.id,
      e.message.id,
      e.author.id,
      e.message.timestamp,
      e.message.content
    ])
  end
end

bot.message_edit do |e|
  botdb.query(MSGLOG_EDIT, [
    e.channel.id,
    e.message.id,
    e.message.edit_timestamp,
    e.message.content
  ])
end

bot.message_delete do |e|
  botdb.query(MSGLOG_DELETE, [
    e.channel.id,
    e.id
  ])
end

bot.run