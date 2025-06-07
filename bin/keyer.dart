//import 'dart:convert';
import 'dart:io';
import 'package:libserialport/libserialport.dart';
import 'alphabet.dart' as alphabet;
import 'helptext.dart';
import 'macros.dart' as macros;

/// Keyer creates a CLI program to utilize a serial
/// port key line for sending Morse code via a radio
class Keyer {
  /// the serial port to connect with
  String _port = '/dev/ttyUSB0';
  /// the default sending speed in WPM
  int _speed = 20;
  /// the calculated millisecond length of a DIT
  int _dit = 60; // 1200/speed in WPM
  /// the calculated millisecond length of 3 DITs (DAH)
  int _3dit = 180; // 3 dit lengths at WPM
  /// the calculated millisecond length of a word space
  int _6dit = 360;
  /// SerialPort object for read/write to the radio
  late SerialPort _modem;
  /// the configuration values for the serial port
  late SerialPortConfig spc;
  /// carriage return followed by line feed
  final String CRLF = '\r\n';
  /// prompt character
  final String PROMPT = '> ';
  /// user call sign or prompt text
  String _mycall = 'rtskeyer';
  /// toggle debug mode
  bool _debug = false;
  
  /// Create an object and calculate the running state values
  Keyer(int speed, String port, {String mycall = 'rtskeyer', bool debug = false})
  :_speed = speed, _port = port, _mycall = mycall, _debug = debug
  {    
    _dit = (1200/_speed).toInt();
    _3dit = _dit * 3;    
    _6dit = _dit * 6;   
    print('keyer $_speed $_port $_mycall');
    getSerialPort(_port);
    listenKeys(); 
  }

  /// given the String [line], send the characters in Morse code
  void sendCharacters(String line) {
    if(_debug) { print("Dit duration: $_dit"); }
    String abet;
    for(int i = 0; i < line.length; ++i) {
      abet = alphabet.alphabet[line[i].codeUnits.first];
      stdout.write(line[i]);      
      for(int j = 0; j < abet.length; ++j) {
        if(abet[j] == '.') { keyDown(_dit); }
        else { keyDown(_3dit); }
        keyUp(_dit);
      }
      keyUp(_3dit);
    }
    stdout.write(CRLF);
    keyUp(_6dit);    
  }

  /// gather, open and apply the settings to the serial port
  Future<void> getSerialPort(String portname) async {
    print("Opening Serial Port : $portname");
    // for(var s in SerialPort.availablePorts) {
    //   print("Port: $s");
    // }
    // open the serial port to the "keyer"
    bool open = false;
    spc = SerialPortConfig();
    // seems to work fine at this speed, but slower also works
    spc.baudRate = 9600; 
    spc.bits = 8;
    spc.parity = 0;
    spc.stopBits = 1;
    spc.setFlowControl(SerialPortFlowControl.none);
    spc.rts = 0;
    _modem = SerialPort(portname); // i.e. ttyUSB0
    try {
      open = _modem.openReadWrite();
      _modem.config = spc;
      
      if (open) {
        print("Serial Port         : $portname is open!");
        print('Speed set to        : $_speed WPM');
        print('My callsign         : $_mycall');
        final reader = SerialPortReader(_modem);
          reader.stream.listen((data) {
          if(_debug) { print('received: $data'); }
        });        
      } 
      else {
        print("Serial Port $portname: NOT OPEN!");
        _modem.close();
      } 
    }
    catch (se) {
      // connection to device failed, so
      print('SerialException: ${se.toString()} addr:$portname');
    }
  }

  /// the key circuit is on for durationMs
  void keyDown(int durationMs) {
    spc.rts = 1;
    _modem.config = spc;
    sleep(Duration(milliseconds: durationMs));
    spc.rts = 0;
    _modem.config = spc;
  }

  /// the key circuit is off for durationMs
  keyUp(int durationMs) {
    sleep(Duration(milliseconds: durationMs));
  }

  /// save the settings to a json file named settings.json
  void saveSettings() {
    print('save settings: $_speed $_port $_mycall');
    var settings = File('settings.json');
    var jsontext = '{"speed":$_speed,"mycall":"$_mycall","port":"$_port"}';
    settings.writeAsBytesSync(jsontext.codeUnits);
  }

  /// gather key strokes from the user and act by either
  /// sending the data in Morse code or performing an action
  /// to change the configuration or call up a macro text
  void listenKeys() async  {
    String check = '';
    while(true) {
      stdout.write('$_mycall$PROMPT');
      var lineIn = stdin.readLineSync();
      if(lineIn == null || lineIn.isEmpty) { continue;}
      // Test the input line for command strings first
      // and if not a command/config, send the text
      check = '';
      check = lineIn.trim(); // clean the line of extra white space
      // check each command in order of typical use for efficiency
      // print("check: $check");
      if(check.startsWith('@@')) {
        print("Speed set to: ${check.substring(2)} WPM");
        // handle speed change with the text
        _speed = int.parse(check.substring(2).trim());
        _dit = (1200/_speed).toInt();
        _3dit = _dit *3;
        _6dit = _dit* 6;
        continue;
      }
      else if(check.startsWith('^')) {
        if(check.startsWith('^^')) {
          print('${macros.printList()}');
          continue;
        }
        var idx = check.substring(1);
        if(idx.isEmpty) { continue; }
        var macro = macros.getMacro(int.parse(idx));
        print('Sending Macro: ${check.substring(1)} - $macro');
        sendCharacters(macro);        
        continue;
      }
      else if(check.startsWith('??') ) {
        print(helptext);
        continue;
      }
      else if(check.startsWith('##')) {
        // print("\x1B[2J\x1B[0;0H"); // clear entire screen, move cursor to 0;0
        if(Platform.isWindows) {
          print(Process.runSync("cmd", ['C "cls"'], runInShell: true).stdout);
        } else {
          print(Process.runSync("clear", [], runInShell: true).stdout);
        }
        continue;
      }
      else if(check.startsWith('exit') || check.startsWith('EXIT') ) {
        exit(0);
      }
      else if(check.startsWith('~~')) {
        // save the config to shared_preferences
        saveSettings();
        print('Settings saved!');
        continue;
      }
      else if(check.startsWith('<<')) {
        // set the port name path i.e. /dev/ttyUSB1
        print('port check: $check');
        _port = check.substring(2).trim();
        print('port:$_port');
        saveSettings();
        getSerialPort(_port);
        continue;
      }
      // send the chars via Morse
      sendCharacters(lineIn);
    }
  }

}