import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geodesy/geodesy.dart';


class MapScreen extends StatelessWidget {
  final double firstlat;
  final double firstlong;
  final double secondlat;
  final double secondlong;
  const MapScreen({Key? key, required this.firstlat, required this.firstlong, required this.secondlat, required this.secondlong}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng myLocation = LatLng(firstlat, firstlong);
    final LatLng otherLocation = LatLng(secondlat, secondlong);
    final Geodesy geodesy = Geodesy();
    final num distance = geodesy.distanceBetweenTwoGeoPoints(myLocation, otherLocation);

    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Distance'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: myLocation,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 30.0,
                height: 30.0,
                point: myLocation,
                builder: (ctx) => Container(
                  child: FlutterLogo(),
                ),
              ),
              Marker(
                width: 30.0,
                height: 30.0,
                point: otherLocation,
                builder: (ctx) => Container(
                  child: FlutterLogo(),
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [myLocation, otherLocation],
                color: Colors.blue,
                strokeWidth: 2.0,

                // onTap: () {
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Text('Distance'),
                //         content: Text('Distance: $distance meters'),
                //         actions: <Widget>[
                //           TextButton(
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //             child: Text('OK'),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
