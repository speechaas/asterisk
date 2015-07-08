# SpeechAAS asterisk scripts

SpeechAAS - "Speech as a Service" provides high-grade multilingual TTS and ASR.  This repository contains Asterisk AGI scripts to interface with SpeechAAS.

Basic setup
===========

Create a file, /etc/speechaas.conf, containing two lines:  
key {key}  
region {region}  
where {key} is your API key, found when you log in to http://speechaas.com  
and {region} is your continent - one of na, sa, eu, af, as, au  

We have geographically redundant insfrastructre, with PoPs on four continents, and selecting
your region correctly will allow your API calls to be routed to the nearest server - thus
keeping latencies low.

TTS
===

To install, download tts.pl and install in /var/lib/asterisk/agi-bin.  Check that it's working by running the script manually:  
`perl tts.pl "My name is Bond. James Bond." en-GB male debug`  
If all's well, you'll get a message confirming that the TTS succeeded and the WAV file where the audio can be found.

The sample extensions-tts.conf in this repository shows how to call the TTS service.  The text to speak and language are mandatory, gender optional and only a request - if we only have a voice for the language required of a different gender to that requested, we'll use the available voice.

As well as speaking text, the TTS engine can speak the contents of a file.  In this case, replace the text to speak with the name of the file, prefixed with 'file:' - an example being file:/tmp/test.ssml  Text may also be prefixed by 'text:'

The TTS engine will speak either plain text or SSML.

We also provide a stand-alone executable, tts, which is a bundle of the Perl interpreter, libraries and the script.  This can be invoked for testing with:  
`./tts "Hello" en-GB male debug`  

ASR
===

To install, download asr.pl and install in /var/lib/asterisk/agi-bin, and configure /etc/speechaas.conf in the same way as above.

Alternatively, there is again a stand-alone executable, build in the same way, called asr.

extensions-asr.conf provides a simple test of the TTS and ASR services.  ASR requests require a grammar, and there's a simple grammar use by this test in test.grxml

Languages supported are:  
ca-ES  
da-DK  
de-DE  
en-AU  
en-CA  
en-GB  
en-IN  
en-US  
es-ES  
es-MX  
fi-FI  
fr-CA  
fr-FR  
it-IT  
ja-JP  
ko-KR  
nb-NO  
nl-NL  
pl-PL  
pt-BR  
pt-PT  
ru-RU  
sv-SE  
zh-CN  
zh-HK  
zh-TW  
