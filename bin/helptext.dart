final String helptext = '''
RTS Keyer Help
-Invocation: ./rtskeyer <speed> <serial port>
-The "command line" looks like "ab4mw> ".  All commands and 
text to send are entered here.  To send text in Morse code via the
serial port's RTS signal, simply type the text and/or prowords
(defined below) and press the <Enter> (or <Return>) key.  As each
character is sent, it will be echoed to the screen.
-Command List
~~ (tilde tilde) means "Save the current settings to shared preferences"
?? means display this help text
@@nn means "Change the keying speed to the one or two digit speed"
^n looks up the macro substitution text from macros.json and send it.
^^ will print a list of defined macros contained in the macros.json file.
## will clear the screen of all text and revert to the cmd line.
-The text literal 'exit' or 'EXIT' will close the program.
-Prosigns SK  %, AR  >, KN  +, BT =
''';