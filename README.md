A stdin/stdout application to send Morse code using a serial RTS keying device

Just one example, which I use:

https://www.ebay.com/itm/355950221050?mkcid=16&mkevt=1&mkrid=711-127632-2357-0&ssspo=8gUlvEMKShm&sssrc=2047675&ssuid=7YI7a7yESla&widget_ver=artemis&media=COPY

A device such as this will toggle the RTS line of a serial port from its
internal USB to RS-232 converter.  Most radios have 3.5mm keying ports now, so
this little device can be used to key a radio when the radio is set into
straight key mode (like a keyer device).

The program expects the USB/Serial device to be ready when the program starts.

Once the program starts, you will then notice a prompt "Enter text > ".  

Type in the text to send by Morse code and it will be keyed to the radio (or code practice oscillator).
