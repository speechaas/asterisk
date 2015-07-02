# SpeechAAS asterisk scripts

SpeechAAS - "Speech as a Service" provides high-grade multilingual TTS and ASR.  This repository contains Asterisk AGI scripts to interface with SpeechAAS.

As of now, there is one script which allows Asterisk to access SpeechAAS' TTS service.

To install, download tts.pl and install in /var/lib/asterisk/agi-bin.  You'll need to copy your API key (log in to http://www.speechaas.com to find it) into the script.  Check that it's working by running the script manually:  
`perl tts.pl "My name is Bond. James Bond." en-GB male debug`  
If all's well, you'll get a message confirming that the TTS succeeded and the WAV file where the audio can be found.
