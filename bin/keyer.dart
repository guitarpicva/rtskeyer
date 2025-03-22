// import 'dart:typed_data';
import 'dart:io';
import 'package:libserialport/libserialport.dart';
import 'alphabet.dart' as alphabet;
import 'helptext.dart';
import 'macros.dart' as macros;

class Keyer {
  String _port = '/dev/ttyUSB0';
  int _speed = 20;
  int _dit = 60; // 1200/speed in WPM
  int _3dit = 180; // 3 dit lengths at WPM
  int _6dit = 360; // word space 6 dit lengths at WPM
  late SerialPort _modem;
  late SerialPortConfig spc;
  final String CRLF = '\r\n';
  final String PROMPT = '> ';
  String _mycall = 'rtskeyer';
  bool _debug = false;
  
  Keyer(int speed, String port, {String mycall = 'rtskeyer', bool debug = false})
  :_speed = speed, _port = port, _mycall = mycall, _debug = debug
  {    
    _dit = (1200/_speed).toInt();
    _3dit = _dit * 3;    
    _6dit = _dit * 6;   
    getSerialPort(_port);
    listenKeys(); 
  }

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

  Future<void> getSerialPort(String portname) async {
    print("Open Serial Port: $portname");
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
        print("Serial Port: $portname is open!");
        print('Speed set to: $_speed WPM');
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
      // connection to radio failed, so
      // tell the UI to open the configuration Drawer
      print('SerialException: ${se.toString()} addr:$portname');
    }
  }

  void keyDown(int durationMs) {
    spc.rts = 1;
    _modem.config = spc;
    sleep(Duration(milliseconds: durationMs));
    spc.rts = 0;
    _modem.config = spc;
  }

  keyUp(int durationMs) {
    sleep(Duration(milliseconds: durationMs));
  }

  void listenKeys() async  {
    String check = '';
    while(true) {
      stdout.write('$_mycall$PROMPT');
      //var lineIn = await stdin.readLineSync();
      var lineIn = stdin.readLineSync();
      if(lineIn == null || lineIn.isEmpty) { continue;}
      // Test the input line for command strings first
      // and if not a command/config, send the text
      check = '';
      check = lineIn.length > 3 ? lineIn.substring(0,4): lineIn; // first 4 chars may be a command
      // check each command in order of typical use for efficiency
      // print("check: $check");
      if(check.startsWith('@@')) {
        print("Speed set to: ${check.substring(2)} WPM");
        // handle speed change with the text
        _speed = int.parse(check.substring(2));
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
        print('Sending Macro: ${check.substring(1)}');
        var macro = macros.getMacro(int.parse(check.substring(1)));
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
      }
      else if(check.startsWith('exit') || check.startsWith('EXIT') ) {
        exit(0);
      }
      else if(check.startsWith('~~')) {
        // save the config to shared_preferences
        print('Settings saved!');
        continue;
      }
      // send the chars via Morse
      sendCharacters(lineIn);
    }
  }

}