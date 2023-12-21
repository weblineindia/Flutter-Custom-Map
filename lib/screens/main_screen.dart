import 'package:flutter/material.dart';
import 'package:flutter_custom_map/screens/widget/custom_map_component.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? sourceLatLng;

  LatLng? destinationLatLng;

  void onMapCreated(LatLng latLng) {
    //put required code
    sourceLatLng = latLng;
    setState(() {});
  }

  void onMapClick(LatLng latLng) {
    //put required code
    destinationLatLng = latLng;
    setState(() {});
  }

  void navigationCLick() async {
    if (sourceLatLng == null || destinationLatLng == null) return;
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${sourceLatLng?.latitude},${sourceLatLng?.longitude}&destination=${destinationLatLng?.latitude},${destinationLatLng?.longitude}&travelmode=driving&dir_action=navigate';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CustomMap'),
        centerTitle: true,
      ),
      body: Container(
        child: CustomMapComponent(
          onMapCreated: onMapCreated,
          onMapClick: onMapClick,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions),
        onPressed: navigationCLick,
      ),
    );
  }
}
