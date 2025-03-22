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
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart rtskeyer.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  int speed = 15;
  String port = '/dev/ttyUSB0';
  String mycall = 'rtskeyer';

  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('rtskeyer version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    speed = int.parse(results.arguments[0]);
    port = results.arguments[1];
    mycall = results.arguments[2];
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
    
    // start the keyer process which loops looking for ASCII
    // text from the keyboard to send via Morse code
    Keyer(speed, port , mycall: mycall);

  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
