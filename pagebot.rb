#!/usr/bin/env ruby

require 'cinch'
require 'circular_queue'

$buffers = {}

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#cinch-bots"]
    c.nick = "hjkl"
  end

  # on :message do |m|
  #   $buffers[nick] 
  # end

  on :message, /!PRIVMSG (.+?) (.+)/ do |m, nick, message|
    m.reply "Hello, #{m.inspect}"
  end
end

bot.start