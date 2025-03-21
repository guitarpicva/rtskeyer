import 'dart:typed_data';
import 'dart:io';
import 'package:libserialport/libserialport.dart';
import 'alphabet.dart' as alphabet;

class Keyer {
  String _port = '/dev/ttyUSB0';
  int _speed = 20;
  int _dit = 60; // 1200/speed in WPM
  int _3dit = 180; // 3 dit lengths at WPM
  int _6dit = 360; // word space 6 dit lengths at WPM
  String mycall = 'DE AB4MW >';
  late SerialPort _modem;
  late SerialPortConfig spc;
  final String CRLF = "\r\n";
  
  Keyer(int speed, String port)
  :_speed = speed, _port = port
  {    
    _dit = (1200/_speed).toInt();
    _3dit = _dit * 3;    
    _6dit = _dit * 6;   
    getSerialPort(_port);
    listenKeys(); 
  }

  void sendCharacters(String line) {
    // print("Dit duration: $_dit");    
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
    for(var s in SerialPort.availablePorts) {
      print("Port: $s");
    }
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
        sendCharacters(mycall);
        final reader = SerialPortReader(_modem);
          reader.stream.listen((data) {
          print('received: $data');
          Uint8List send = Uint8List.fromList("hello".codeUnits);
          _modem.write(send);
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
    while(true) {
      stdout.write("Enter text >");
      var lineIn = await stdin.readLineSync();
      //var input = await stdin.pipe();
      // print('lineIn: $lineIn');
      sendCharacters(lineIn!);
    }
  }

}