# pagebot

A bot to listen on IRC for a regex match, and notify a Slack room with the relevant mentions. Because you can't pay attention to every chat system all the time.

Despite having a reasonable config file, Pagebot is still hackware.

## Installation

git-clone or scp the repo to the target machine.

## Usage

Pagebot expects a file at `config/bot_config.rb`, with the following constants. An example file is at `bot_config.rb.example`.

    SLACK_URL = "the Slack URL to post to",
    SLACK_ROOM = "Ops"
    REGEX = %r{wensleydale|cheddar|ed[ae]m}i

    IRC_SERVER = "irc.freenode.net"
    NICK = "bot_irc_nick"
    NICKSERV_PASSWORD = "top-loading fruit"
    CHANNELS = ["#edam", "#port_salut"]

    RATE_LIMIT_PERIOD_SEC = 360
    MENTIONS_PER_LIMIT_PERIOD = 2

Do `bundle install` to make sure the necessary gems are installed. Depending on your environment, `bundle exec` can probably be omitted.

The recommended way is to run Pagebot under the handy [daemons](https://github.com/ghazel/daemons) gem, which will restart it if it crashes. Sometimes it stays connected to IRC but stops passing notifications; I have a cronjob kick it every night. (Scheduled restarts can probably be done using the `daemons` API; PRs welcome.)

    ./ctl_pagebot start

The control script also supports the standard `stop`, `status`, and `restart` subcommands.

You can run the script directly in the foreground, which will default to connecting to [FreeNode](https://freenode.net/):

    ./pagebot

or in debug mode, which forces it to connect to a local `ircd`. I use [ngircd](http://ngircd.barton.de/index.php.en), probably available through your local package system; it requires no configuration, and speeds up development considerably compared to connecting to a public IRC network. (Specifically, I use `ngircd -np`.)

    ./pagebot -d

Feel free to ask questions via Github issues.
