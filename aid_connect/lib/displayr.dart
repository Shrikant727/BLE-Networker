import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mapscreen.dart';


class Display extends StatelessWidget {
  final Map<String,dynamic> data;
  final double yourLatitude;
  final double yourLongitude;
  Display({Key? key, required this.data, required this.yourLatitude, required this.yourLongitude}) : super(key: key);
  late AssetsAudioPlayer player = AssetsAudioPlayer.newPlayer();
  @override
  Widget build(BuildContext context) {
    Map<int,String> m={0:'police',1:'medical'};
    playaud();
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency occurred'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          children: [
            Center(
                child:Text(
                "Emergency ${m[data['code']]} assistance required by:\n ${data['phone']}",
                )
            ),
            ElevatedButton(style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),onPressed: stopaud, child: Text('Stop Ringing')),
      Container(
        child:
          MapScreen(firstlat: yourLatitude, firstlong: yourLongitude, secondlat: data['lat'], secondlong: data['long']),
      ),
          ],
        ),
      ),
    );
  }
  Future<void> playaud() async {
    player.open(
      Audio("assets/audio/emergency.mp3"),
      autoStart: true,
    );
  }
  Future<void> stopaud() async {
    player.stop();
  }
}




