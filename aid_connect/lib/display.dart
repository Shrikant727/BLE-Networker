import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Display extends StatelessWidget {
  final Uint8List data;
  const Display({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    int counter=data[2];
    String phone="";
    int code=0;
    Map<int,String> m={0:'police',1:'medical'};
    if(data.length>=4)phone+=data[3].toString();
    if(data.length>=5)phone+=data[4].toString();
    if(data.length>=6)phone+=data[5].toString();
    if(data.length>=7)phone+=data[6].toString();
    if(data.length>=8)phone+=data[7].toString();
    if(data.length>=9)code=data[8];
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency occurred'),
      ),
      body: Center(
          child:Text(
          "Emergency ${m[code]} assistance required by::\n ${phone}",
          )
      ),
    );
  }
}
void playRingtone() {
  AudioCache player = AudioCache();
  player.load('ringtone.mp3');
}