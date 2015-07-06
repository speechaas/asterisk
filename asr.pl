#!/usr/bin/perl
use File::Temp qw/tempfile/;
use File::Slurp;
use JSON;
use LWP::UserAgent;
use LWP::UserAgent::DNS::Hosts;
use URI::Escape;
use Encode;
use Data::Dumper;
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

my $uri = "https://api.speechaas.com:443/asr";

# Get AGI parameters
my $grammar = read_file($ARGV[0]);
my $language = $ARGV[1];
my $audio_file = $ARGV[2];
my $debug = defined($ARGV[3]) ? 1 : 0;

# Plus AGI headers - read and discard
if (!$debug) {
  while (<STDIN>) {
    chomp;
    last if (!length);
  }
}

# Make request to ASR server
my $ua = LWP::UserAgent->new();
my $res = $ua->post(
		$uri, 
		Content_Type => "form-data",
		Authorization => "basic $key",
		Content => [
			grammar => $grammar,
			language => $language,
			file => [ $audio_file, $audio_file, Content_Type => "audio/wav" ]
		]
); 

# Check result
if ($res->status_line !~ /^200/) {
    print STDERR "ASR failed: " . $res->status_line;
} else {
  # OK response - decode and return
  my $ret = decode_json($res->content);
  if ($ret->{success}) {
    print "SET VARIABLE ASR_CONFIDENCE " . int($ret->{result}->{confidence}*100) . "\n";
    if ($ret->{result}->{confidence} > 0) {
      print "SET VARIABLE ASR_RESULT \"" . $ret->{result}->{result} . "\"\n";
    } else {
      print "SET VARIABLE ASR_RESULT \"\"\n";
    }
  } else {
    die "ASR failed: $ret->{msg}";
  }
}
