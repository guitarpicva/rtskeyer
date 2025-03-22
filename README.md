A stdin/stdout application to send Morse code using a serial RTS keying device

Just one example, which I use:

https://www.ebay.com/itm/355950221050?mkcid=16&mkevt=1&mkrid=711-127632-2357-0&ssspo=8gUlvEMKShm&sssrc=2047675&ssuid=7YI7a7yESla&widget_ver=artemis&media=COPY

A device such as this will toggle the RTS line of a serial port from its
internal USB to RS-232 converter.  Most radios have 3.5mm keying ports now, so
this little device can be used to key a radio when the radio is set into
straight key mode (like a keyer device).

 This should work with any RS-232 serial port, however, be mindful of any odd
 keying voltages particularly from older radios.  Modern radios can usually 
 deal with the RTS keying just fine.

 Check your signal with a remote SDR or a friend to ensure that there are no
 keying clicks audible over the air.  If so a key click capacitor might have to
 be introduced to avoid this.  I have not found it to be the case using the
 USB to RS-232 RTS keying device linked above.

The program expects the USB/Serial device to be ready when the program starts.

Once the program starts, you will then notice a prompt "CALLSIGN> ".  If no
callsign is supplied it will read "rtskeyer>".

Type in the text to send by Morse code and it will be keyed to the radio (or code practice oscillator).

Invocation example: ```./rtskeyer 20 /dev/ttyUSB0 ab4mw```  would start the program 
set at 20 WPM speed, using serial port /dev/ttyUSB0 and showing the callsign
'ab4mw' at the command prompt.

The command prompt also includes a couple of commands.

@@nn changes the set speed in WPM, example to change to 22 WPM send @@22 at the command line.

~~ is meant to trigger a save of current configuration to shared_preferences
but this is not yet implemented and is left as a placeholder.  This may simply 
be implemented as a config file on the file system, but the thought is to 
use shared preferences so this may be run on Android/iOS as well as Linux and
Windows

The literal command 'exit' at the start of the command line will immediately
close the program.

INSTALLATION REQUIREMENTS: libserialport0 (pkg name in Debian and derivatives,
so ```sudo apt install libserialport0```