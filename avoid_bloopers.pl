# irssi-avoid-bloopers
# ====================
# 
# A simple script for irssi to avoid sending misspelled commands as messages to a channel.
#
# The most current version can be found at https://github.com/worblehat/irssi-avoid-bloopers.
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
# TODO
# -----------
# - allow user defined cmdchars
# - handle aliases
# - handling of two word commands needed?
# - only do processing when active window is channel or query
#

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

# Get minimum and maximum length of commands
our $max_len = 0;
our $min_len = 512;  

our @commands = (Irssi::commands());
foreach my $cmd (@commands) {
    my $keyword = $cmd->{cmd};
    $min_len = min($min_len, length($keyword));
    $max_len = max($max_len, length($keyword));
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
    for my $cmd (Irssi::commands()) {
        my $keyword = $cmd->{cmd};
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
