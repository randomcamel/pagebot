# pagebot

A bot to listen on IRC for a regex match, and notify a HipChat room with the relevant mentions. Because you can't pay attention to every chat system all the time.

Pagebot is still hackware, and lacks niceties like a config file.

## Installation

git-clone or scp the repo to the target machine.

## Usage

Pagebot expects a file called `secrets.rb`, with the following contents:

    HIPCHAT_API_KEY = "your HipChat v2 API key here"

You can run the script directly, which connects it to the FreeNode IRC network:

    ./pagebot

or in debug mode, which forces it to connect to a local `ircd`. I use [ngircd](http://ngircd.barton.de/index.php.en), probably available through your local package system; it requires no configuration and speeds up development considerably compared to connecting to a public IRC network.

    ./pagebot -d

Finally, there's a control script to run Pagebot under the handy [daemons](https://github.com/ghazel/daemons) gem, which will restart it if it crashes. I did once see the bot fail to work even though it was running, but mostly it seems to be okay.

    ./ctl.rb start

