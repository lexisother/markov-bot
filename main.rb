require 'discordrb'

require_relative 'database'
require_relative 'config'

bot = Discordrb::Bot.new token: BOT_CONFIG[:token]
botdb = Scrap::Database.new({ dbname: 'realbot' })

MSGLOG_NEW = %(insert into discord_log (cid, mid, uid, mtime, mdata) values ($1, $2, $3, $4, $5)).freeze
MSGLOG_EDIT = %(update discord_log set etime = $3, edata = $4 where cid = $1 and mid = $2).freeze
MSGLOG_DELETE = %(update discord_log set del = true where cid = $1 and mid = $2).freeze

bot.message do |e|
  botdb.query(MSGLOG_NEW, [
    e.channel.id,
    e.message.id,
    e.author.id,
    e.message.timestamp,
    e.message.content
  ])
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