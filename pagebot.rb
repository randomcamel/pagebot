#!/usr/bin/env ruby

require 'circular_queue'
require 'hipchat'
require 'summer'

require 'logger'
require 'pry'

# hipchat key.
require_relative 'secrets'

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

require 'net/smtp'

class Mailer
  def self.send_email(to,opts={})
    opts[:server]      ||= 'localhost'
    opts[:from]        ||= 'email@example.com'
    opts[:from_alias]  ||= 'Example Emailer'
    opts[:subject]     ||= "You need to see this"
    opts[:body]        ||= "Important stuff!"

    msg = <<-END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

    Net::SMTP.start(opts[:server]) do |smtp|
      smtp.send_message msg, opts[:from], to
    end
  end
end
class Bot < Summer::Connection
  HIPCHAT_ROOM = "Windows"
  RATE_LIMIT_PERIOD_SEC = 360
  MENTIONS_PER_LIMIT_PERIOD = 2

  def initialize(*args)
    @hipchat = HipChat::Client.new(HIPCHAT_API_KEY, :api_version => 'v2')
    @mention_count = 0
    @latest_period_start = Time.now - RATE_LIMIT_PERIOD_SEC
    @log = Logger.new STDOUT

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
#{Time.now.strftime('%H:%M')} #{channel}: <#{sender[:nick]}> #{message}
EOS
    if within_rate_limit?
      @hipchat[HIPCHAT_ROOM].send("pagebot", msg, :color => "yellow", :message_format => "text")
      count_notification!
    end
  end

  def channel_message(sender, channel, message)
    if message =~ /windows|dsc[\W]*|microsoft|msft|powershell|winrm/i
      notify_hipchat!(sender, channel, message)
      puts "period start: #{@latest_period_start} ; count: #{@mention_count}"
    end
  end
end

@log = Logger.new STDOUT

Dir.chdir(File.dirname(File.expand_path(__FILE__)))

if ARGV.size == 0
  Bot.new("irc.freenode.net")
elsif ARGV[0] == "-d"
  Bot::HIPCHAT_ROOM = "IRC 2"
  Bot.new("localhost")
else
  @c = HipChat::Client.new(HIPCHAT_API_KEY, :api_version => 'v2')
  binding.pry
end
