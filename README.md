# discourse-login

Simple shell script that helps getting the "Devotee" Discourse badge (for
visiting a website for 365 consecutive days).

## Usage

First, make sure you have [curl](https://curl.haxx.se/) and
[sed](https://www.gnu.org/software/sed/) installed. Then, in the repository
clone directory, execute:

```bash
cp discourse-login.conf.example $HOME/.config/discourse-login.conf
$EDITOR $HOME/.config/discourse-login.conf
```

Using the editor, change the variables to the match the forum you want to visit
every day. Make sure `DISCOURSE_URL` does **not** contain trailing slash, and
`DISCOURSE_TO_VISIT` is a relative URL to the topic you want to visit after
signing in (ideally, this should be a topic that requires authentication
to make sure that the user was successfully signed in). Now, executing
`./discourse-login.sh` should give an output similar to the following:

```
$ ./discourse-login.sh
Visited the website successfully at Sat Jul  7 15:19:28 CEST 2018
```

If so, it means that everything is set up properly! You can now copy the script
to `/usr/bin` or `~/.local/bin` if you want. You should also change the
configuration file permissions to 600/400 to make sure nobody but you (in
the OS) can read it.

## cron

It makes the most sense to run the utility every day, or even twice a day.
The simplest way to do so is to set up a cron job. Execute `crontab -e` then,
and paste the following at the end of the file that just showed up:

```
0 */12 * * * $HOME/.local/bin/discourse-login >> /var/log/discourse-login/discourse-login.log
``` 

This will instruct cron to run the script every 12 hours. You should of course
substitute `$HOME/.local/bin/discourse-login` with your own installation path,
and create `/var/log/discourse-login/` directory (with write access for your
local user) or change this to your favorite logging directory (possibly
`/dev/null`). Since you are only redirecting `STDOUT` to a file, cron will still
email you in case of any errors.
