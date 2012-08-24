#!/usr/bin/env perl -w

use strict;

use Irssi;
use URI::Escape;

use vars qw($VERSION %IRSSI);
$VERSION = '1.0';
%IRSSI = (
  authors     => 'Jared Branum',
  contact     => 'jared.branum@gmail.com',
  name        => 'growl_tunnel',
  license     => 'MIT',
  description => 'A set of scripts to get growl alerts locally '.
                 'from a remote irssi session through SSH',
  url         => 'https://github.com/jaredbranum/irssi_growl_tunnel'
);

# listen for private msgs
sub privmsg {
  my ($server, $msg, $nick) = @_;
  tunnel_growl($nick, $msg);
}

# listen for highlights
sub highlight {
  my ($dest, $text, $stripped) = @_;
  my ($channel, $level) = ($dest->{target}, $dest->{level});
  if ($level & MSGLEVEL_HILIGHT){
    tunnel_growl($channel, $stripped);
  }
}

# send growl alerts
sub tunnel_growl {
  my ($title, $msg) = @_;
  my ($encoded_title, $encoded_msg) = (uri_escape($title), uri_escape($msg));
  my $params = "title=$encoded_title&message=$encoded_msg";
  $params =~ s/\"/\\\"/g;
  system "curl -s -d \"$params\" http://localhost:55573"
}

Irssi::signal_add_last("message private", "privmsg");
Irssi::signal_add_last("print text", "highlight");
