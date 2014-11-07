
# bug still in master.
module Summer
  class Connection
    def privmsg(to, message)
      response("PRIVMSG #{to} :#{message}")
    end
  end
end
