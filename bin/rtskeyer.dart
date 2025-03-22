import 'package:args/args.dart';
import 'keyer.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'debug',
      abbr: 'd',
      negatable: false,
      help: 'Show debug trace output.',
    )
    ..addFlag(
      'version', 
      abbr: 'v',
      negatable: false, 
      help: 'Print the version string.'
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart rtskeyer.dart <flags> [<speed> <port> <callsign>]');
  print(argParser.usage);
  print('\nArguments are, in order:\n\nspeed in WPM integer\nserial port name\nprompt text (typically the callsign)');
  print('Example: ./rtskeyer 22 /dev/ttyUSB0 ab4mw');
}

void main(List<String> arguments) {
  int speed = 15;
  String port = '/dev/ttyUSB0';
  String mycall = 'rtskeyer';

  final ArgParser argParser = buildParser();

  try {
    final ArgResults results = argParser.parse(arguments);
    bool debug = false;
    print('flag(s) and args: ${results.arguments}');
    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('rtskeyer version: $version');
      return;
    }
    if (results.flag('debug')) {
      print('STARTING DEBUG MODE...');
      debug = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    try {
      int cnt = results.rest.length;
      print('argument count: $cnt');
      if(cnt > 0 ) {
        speed = int.parse(results.rest[0]);
      }
      if(cnt > 1) {
        port = results.rest[1];
      }
      if(cnt > 2) {
        mycall = results.rest[2];
      }
    }
    catch (e) {
      print('\nError in evaluation of cmd line args!\n');
      printUsage(argParser);
      return;
    }
    if (debug) {
      print('[DEBUG] All arguments: ${results.arguments}');
    }  
    // start the keyer process which loops looking for ASCII
    // text from the keyboard to send via Morse code or commands
    // to control the keyer
    Keyer(speed, port , mycall: mycall, debug: debug);
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }

}
