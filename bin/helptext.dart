final String helptext = '''
RTS Keyer Help

Invocation: ./rtskeyer <speed> <serial port>

The "command line" looks like "<mycall>> ".  All commands and 
text to send are entered here.  To send text in Morse code via the
serial port's RTS signal, simply type the text and/or prowords
(defined below) and press the <Enter> (or <Return>) key.  As each
character is sent, it will be echoed to the screen.

Command List
~~ means "Save the current settings to shared preferences"
?? means display this help text
@@nn means "Change the keying speed to the one or two digit speed"
exit or EXIT will close the program

Prosigns/Prowords
Left side is the prosign to send, and right side is the character to use
at the command line.

SK = %
AR = >
KN = +
BT = - (dash)

''';