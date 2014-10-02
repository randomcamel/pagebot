#!/usr/bin/env ruby

require 'cinch'
require 'circular_queue'
require 'hipchat'
require 'summer'

require 'pry'

# hipchat key.
require './secrets'

# eventually it'd be nice to have surrounding context.
class Rings
  LINE_BUFFER_SIZE = 3

  class <<self
    @rings = {}

    def [](nick)
      @rings[nick] ||= CircularQueue.new(LINE_BUFFER_SIZE)
    end
  end
end

# [3] pry(main)> room = c.create_room("IRC Integration")
# => {"id"=>864742, "links"=>{"self"=>"https://api.hipchat.com/v2/room/864742"}}

class Bot < Summer::Connection
  HIPCHAT_ROOM = "IRC 2"

  def initialize(*args)
    @hipchat = HipChat::Client.new(HIPCHAT_API_KEY, :api_version => 'v2')
    super(*args)
  end

  def channel_message(sender, channel, message)
    if message =~ /windows/i
      privmsg("oink", channel)
      binding.pry
      msg = <<-EOS
IRC alert for @cdoherty:

#{channel}: <#{sender[:nick]}> #{message}
EOS
      @hipchat[HIPCHAT_ROOM].send("cdoherty", msg, :color => "purple", :message_format => "text")
    end
  end
end

if ARGV.size == 0
  Bot.new("localhost")
else
  @c = HipChat::Client.new(HIPCHAT_API_KEY, :api_version => 'v2')
  binding.pry
end