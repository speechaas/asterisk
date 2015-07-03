#!/usr/bin/perl
use File::Temp qw/tempfile/;
use File::Slurp;
use JSON;
use LWP::UserAgent;
use URI::Escape;
use Encode;
use Data::Dumper;
use strict;
use utf8;
$|=1;

# Put your SpeechAAS key here:
my $key = "";

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
