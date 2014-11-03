# pagebot

A bot to listen on IRC for a regex match, and notify a HipChat room with the relevant mentions. Because you can't pay attention to every chat system all the time.

Despite having a reasonable config file, Pagebot is still hackware.

## Installation

git-clone or scp the repo to the target machine.

## Usage

Pagebot expects a file at `config/bot_config.rb`, with the following constants. An example file is at `bot_config.rb.example`.

    HIPCHAT_API_KEY = "your HipChat API v2 key",
    HIPCHAT_ROOM = "Ops"
    REGEX = %r{wensleydale|cheddar|ed[ae]m}i

    IRC_SERVER = "irc.freenode.net"
    NICK = "bot_irc_nick"
    CHANNELS = ["#edam", "#port_salut"]

    RATE_LIMIT_PERIOD_SEC = 360
    MENTIONS_PER_LIMIT_PERIOD = 2

Do `bundle install` to make sure the necessary gems are installed. Depending on your environment, `bundle exec` can probably be omitted.

You can run the script directly, which connects it to the FreeNode IRC network:

    ./pagebot

or in debug mode, which forces it to connect to a local `ircd`. I use [ngircd](http://ngircd.barton.de/index.php.en), probably available through your local package system; it requires no configuration, and speeds up development considerably compared to connecting to a public IRC network. (Specifically, I use `ngircd -np`.)

    ./pagebot -d

Finally, there's a control script to run Pagebot under the handy [daemons](https://github.com/ghazel/daemons) gem, which will restart it if it crashes. I did once see the bot fail to work even though it was running, but mostly it seems to be okay.

    ./ctl_pagebot start

The control script also supports `stop`, `status`, and `restart`.
