#!/usr/bin/perl
use File::Temp qw/tempfile/;
use File::Slurp;
use JSON;
use LWP::UserAgent;
use LWP::UserAgent::DNS::Hosts;
use URI::Escape;
use Encode;
use strict;
use utf8;
$|=1;

# Either put your SpeechAAS key here or in /etc/speechaas.conf with a line reading 'key <key>'
my $key = "";

# Optionally set your continent here (one of na, sa, af, eu, as, au) - this can go in /etc/speechaas.conf as well
my $region = "";

# Get config from config file
open(my $fh, "</etc/speechaas.conf");
if ($fh) {
  while (<$fh>) {
    if ($_ =~ /key\s+([a-zA-Z0-9]+)/) {
      $key = $1;
    }
    if ($_ =~ /region\s+(na|sa|af|eu|as|au)/) {
      $region = $1;
    }
  }
  close $fh;
}

if ($key eq "") {
  print STDERR "No key set\n";
  die;
}

if ($region ne "") {
  my $host = $region . ".api.speechaas.com";
  LWP::UserAgent::DNS::Hosts->register_hosts("api.speechaas.com" => $host);
}

my $uri = "https://api.speechaas.com:443/tts";

# Get AGI parameters
my $text = $ARGV[0];
my $language = $ARGV[1];
my $gender = defined($ARGV[2]) ? $ARGV[2] : "any";
my $debug = defined($ARGV[3]) ? 1 : 0;

# Plus AGI headers - read and discard
if (!$debug) {
  while (<STDIN>) {
    chomp;
    last if (!length);
  }
}

# Text - file or plain text?
if (substr($text, 0, 5) eq "text:") {
  $text = substr($text, 5);
} elsif (substr($text, 0, 5) eq "file:") {
  $text = read_file(substr($text, 5));
}
$text = uri_escape($text);

# Make request to TTS server
my $ua = LWP::UserAgent->new();

my %post = ();
$post{text} = $text;
$post{format} = "wav";
$post{language} = $language;
$post{gender} = $gender;
my $res = $ua->post($uri, Authorization => "basic $key", Content => encode_json(\%post));

# Check result
if ($res->status_line !~ /^200/) {
    die "TTS failed: " . $res->status_line;
} else {
  # OK response - check content-type
  if ($res->header("Content-Type") eq "audio/wav") {

    # We have a WAV.. save it as a temporary file, play and delete
    my ($fh, $wav_file) = tempfile(SUFFIX => ".wav");
    print $fh $res->content;
    close $fh;

    if (!$debug) {
      # Strip off the file suffix
      my $wav_file_root = substr($wav_file, 0, -4);

      print "STREAM FILE $wav_file_root \"\"\n";
      my $result = <STDIN>;
    
      unlink($wav_file);
    } else {
      print "TTS succeeded - audio in $wav_file\n";
    }
  } else {
    # We should have a JSON-encoded thing telling us what went wrong
    my $ret = decode_json($res->content);
    die "TTS failed: $ret->{msg}";
  }
}
