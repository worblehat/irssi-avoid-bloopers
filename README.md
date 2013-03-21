irssi-avoid-bloopers
====================

A simple script for irssi to avoid sending misspelled commands as messages to a channel.

Explanation
-----------

When using irssi I often forget or mistype the preceding slash ('/') of irssi- and irc-commands.
This might lead to awkward situations because the command is not recognized as a command and is
send like a normal message to the channel instead.

To avoid such bloopers this script checks if the inserted text might be a command that misses
the essential slash. In that case it prevents the message to be send to the channel and prints
a notification to the user instead.
