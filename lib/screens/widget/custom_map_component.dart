import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomMapComponent extends StatefulWidget {
  CustomMapComponent({
    required this.onMapCreated,
    required this.onMapClick,
    this.markers,
    this.sourcePinpointPath,
    this.destinationPinpointPath,
    this.enableMyLocation,
    this.mapType,
  });

  final Function onMapCreated;
  final Function onMapClick;
  final Set<Marker>? markers;
  final String? sourcePinpointPath;
  final String? destinationPinpointPath;
  final bool? enableMyLocation;
  final MapType? mapType;

  @override
  _CustomMapComponentState createState() => _CustomMapComponentState();
}

class _CustomMapComponentState extends State<CustomMapComponent> {

  Location location = new Location();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  CameraPosition initialLocation = CameraPosition(
    zoom: 16,
    bearing: 14,
    tilt: 0,
    target: LatLng(23.0470, 72.5704),
  );
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMarkers();
  }

  //initialize camera and icons
  void initMarkers() async {
    if (widget.markers != null) {
      _markers.addAll(widget.markers ?? []);
    }
  }

  //callback method when map created
  void onMapCreated(GoogleMapController controller) async {
    print('called');
    _controller.complete(controller);
    LocationData _locationData = await location.getLocation();
    if (_locationData == null) {
      //request for permission
    } else {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        widget.sourcePinpointPath ?? 'assets/images/location.png',
      );

      //add marker to current location
      _markers.add(
        Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng((_locationData.latitude ?? 0), (_locationData.longitude ?? 0)),
          icon: sourceIcon!,
        ),
      );
      //animate camera to lat lng
      animateCamera(_locationData);
    }

    //return callback of created map
    widget.onMapCreated(
      LatLng(
        _locationData.latitude ?? 0,
        _locationData.longitude ?? 0,
      ),
    );
  }

  //animate camera
  void animateCamera(LocationData _locationData) async {
    //move camera to coordinates
    final GoogleMapController controller = await _controller.future;
    final CameraPosition _kLake = CameraPosition(
      target: LatLng(_locationData.latitude ?? 0, _locationData.longitude ?? 0),
      zoom: 16.0,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

    //change state
    setState(() {});
  }

  //on map click
  void onMapClick(LatLng latLng) async{
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      widget.destinationPinpointPath ?? 'assets/images/marker.png',
    );
    _markers.add(
      Marker(
        markerId: MarkerId('destinationPin'),
        position: LatLng(latLng.latitude, latLng.longitude),
        icon: destinationIcon!,
      ),
    );
    setState(() {});

    //return map click function with latlng
    widget.onMapClick(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        myLocationEnabled: widget.enableMyLocation ?? false,
        compassEnabled: false,
        tiltGesturesEnabled: false,
        markers: _markers,
        mapType: widget.mapType ?? MapType.normal,
        initialCameraPosition: initialLocation,
        onMapCreated: onMapCreated,
        onTap: onMapClick,
      ),
    );
  }
}
