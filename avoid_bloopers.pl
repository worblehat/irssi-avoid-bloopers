# irssi-avoid-bloopers
# ====================
# 
# A simple script for irssi to avoid sending misspelled commands as messages to a channel.
# 
# Explanation
# -----------
# 
# When using irssi I often forget or mistype the preceding slash ('/') of irssi- and irc-commands.
# This might lead to awkward situations because the command is not recognized as a command and is
# send like a normal message to a channel (if there is one in the active window).
# 
# To avoid such bloopers this script checks if the inserted text might be a command which preceding slash
# is missing, mistyped or has unintended whitespace in front of it.
# If so, it prevents the message to be send to the channel and prints a notification to the user instead.
# If you really want to send such a blocked message, just send it again (use the command history).
# 
# Alias-Support
# -------------
# So far, only the standard commands are detected when missing the slash.. Aliases as defined in the irssi
# configuration are not recognized by the script. This feature might be added in the future...
# 
# You can add commands manually to the script by modifying the 'commands' array.

use List::Util qw(min max);
use strict;
use warnings;

use Irssi;

our $VERSION = '1.0';
our %IRSSI = (
    authors     => 'Tobias Marquardt',
    contact     => 'tm@tobix.eu',
    name        => 'avoid_bloopers',
    description => 'Avoid sending misspelled commands to a channel.',
    license     => 'GPLv3',
    url         => 'https://github.com/worblehat/irssi-avoid-bloopers',
);

our @commands = (
    'accept', 'die', 'knock', 'note', 'rping', 'unban',  
    'action', 'disconnect',  'knockout', 'notice', 'save', 'unignore',  
    'admin', 'echo', 'lastlog', 'notifiy', 'sconnect', 'unload',    
    'alias', 'eval', 'layout', 'op', 'script', 'unnotify',  
    'away', 'exec', 'links', 'oper', 'scrollback', 'unquery',
    'ban', 'flushbuffer', 'list', 'part', 'server', 'unsilence',
    'beep', 'foreach', 'load', 'ping', 'servlist', 'upgrade',
    'bind', 'format', 'log', 'query', 'set', 'uping',
    'cat', 'hash', 'lusers', 'quit', 'sethost', 'uptime',
    'cd', 'help', 'map', 'quote', 'silence', 'userhost',
    'channel', 'hilight', 'me', 'rawlog', 'squery', 'ver',
    'clear', 'ignore', 'mircdcc',  'recode', 'squit', 'version',
    'completion', 'info', 'mode', 'reconnect', 'stats', 'voice',     
    'connect', 'invite', 'motd', 'redraw', 'statusbar',  'wait',      
    'ctcp', 'ircnet', 'msg', 'rehash', 'time', 'wall',      
    'cycle', 'ison', 'names', 'reload', 'toggle', 'wallops',
    'dcc', 'join', 'nctcp', 'resize', 'topic', 'who', 
    'dehilight', 'kick', 'netsplit', 'restart', 'trace', 'whois',
    'deop', 'kickban', 'network', 'rmreconns', 'ts', 'whowas',
    'devoice', 'kill', 'nick', 'rmrejoins', 'unalias', 'window'
);

# Get minimum and maximum length of commands
our $max_len = 0;
our $min_len = 512;  
foreach my $cmd (@commands) {
    $min_len = min($min_len, length($cmd));
    $max_len = max($max_len, length($cmd));
}

# Global variable that holds the last send text
our $last = '';

sub send_text_handler {
    my($text, $server, $win_item) = @_;
    
    # If send text equals the last send text, just pass it through
    if($text eq $last) {
        return;
    }
    $last = $text;
    # First word of text in lower case
    my $word = lc((split(' ', $text))[0]);
    # Test length of word to prevent unnecessary further processing
    if(length($word) > $max_len || length($word) < $min_len) {
        return;
    }
    # Test for command with preceding (possably unwanted) whitespaces
    if($text =~ m/\s+\/.+/) {
        Irssi::active_win()->print('%RBlocked message%n:'.$text);
        Irssi::active_win()->print('Unintended whitespace in front of command? Resend to send the message anyway.');
        Irssi::signal_stop();
        return;
    }
    foreach my $keyword (@commands) {
        # Test for command with mistyped slash
        if(substr($word, 1) eq $keyword && substr($word, 0, 1) !~ m/\//) {
            Irssi::active_win()->print('%RBlocked message%n:'.$text);
            Irssi::active_win()->print('Mistyped the \'/\' in front of command \''.$keyword.'\'? Resend to send the message anyway.');
            Irssi::signal_stop();
            return;
        }
        # Test for command missing the slash
        elsif($word eq $keyword) {
            Irssi::active_win()->print('%RBlocked message%n:'.$text);
            Irssi::active_win()->print('Command \''.$keyword.'\' missing preceding \’/\’? Resend to send the message anyway.');
            Irssi::signal_stop();
            return;
        }
    }
}

Irssi::signal_add_first 'send text', 'send_text_handler';
