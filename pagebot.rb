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
  RATE_LIMIT_PERIOD_SEC = 30
  MENTIONS_PER_LIMIT_PERIOD = 2

  def initialize(*args)
    @hipchat = HipChat::Client.new(HIPCHAT_API_KEY, :api_version => 'v2')
    @mention_count = 0
    @latest_period_start = Time.now - RATE_LIMIT_PERIOD_SEC

    super(*args)
  end

  def within_rate_limit?
    !(@mention_count >= MENTIONS_PER_LIMIT_PERIOD &&
      (Time.now - @latest_period_start) <= RATE_LIMIT_PERIOD_SEC)
  end

  def count_notification!
    # if we're outside the limit period, reset the period and the count.
    if (Time.now - @latest_period_start) > RATE_LIMIT_PERIOD_SEC
      @latest_period_start = Time.now
      @mention_count = 1
    # otherwise just increment the count.
    else
      @mention_count += 1
    end
  end

  def notify_hipchat!(sender, channel, message)
    msg = <<-EOS
IRC alert for @cdoherty:

#{channel}: <#{sender[:nick]}> #{message}
EOS
    if within_rate_limit?
      @hipchat[HIPCHAT_ROOM].send("cdoherty", msg, :color => "purple", :message_format => "text")
      count_notification!
      privmsg("notified hipchat", channel)
    else
      privmsg("rate-limited to #{MENTIONS_PER_LIMIT_PERIOD} every #{RATE_LIMIT_PERIOD_SEC} seconds",
              channel)
    end
  end

  def channel_message(sender, channel, message)
    if message =~ /xx/i
      notify_hipchat!(sender, channel, message)
      puts "period start: #{@latest_period_start} ; count: #{@mention_count}"
    end
  end
end

if ARGV.size == 0
  Bot.new("localhost")
else
  @c = HipChat::Client.new(HIPCHAT_API_KEY, :api_version => 'v2')
  binding.pry
end