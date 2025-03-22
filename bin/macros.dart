import 'dart:io'; // to read config file
import 'dart:convert'; // to process json files
/// Nine macro definitions as strings
List<String> macros = List<String>.filled(9, '');

String getMacro(int index) {
  //print('getMacro: $index');
  File f = File('bin/macros.json');
  String json = f.readAsStringSync();
  // print(json);
  List<dynamic> macro = jsonDecode(json);
  // print('macro length:${macro.length}');
  if(macro.length >= index) {
    //print(macro[index-1]);
    return macro[index-1];
  }
  else { 
    print('No macro');
    return ''; 
  }
}

String printList() {
  File f = File('bin/macros.json');
  String json = f.readAsStringSync();
  // print(json);
  List<dynamic> macro = jsonDecode(json);
  var list = '';
  int idx = 1;
  macro.forEach((text) {
    list = '$list\n^$idx: $text';
    ++idx;
  });
  // print('macro length:${macro.length}');
  return list;
}