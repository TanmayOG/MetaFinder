import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapDetails extends StatefulWidget {
  final LatLng location;
  final String? Model;
  final String? time;

  const MapDetails({super.key, required this.location, this.Model, this.time});

  @override
  State<MapDetails> createState() => _MapDetailsState();
}

class _MapDetailsState extends State<MapDetails> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static LatLng? loc;

  locate() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      loc = LatLng(position.latitude, position.longitude);
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: loc!,
    zoom: 15.4746,
  );

  @override
  void initState() {
    super.initState();

    setState(() {
      loc = LatLng(widget.location.latitude, widget.location.longitude);
    });
    _determinePosition();
  }

  //

  Future _determinePosition() async {
    try {
      Placemark place =
          (await placemarkFromCoordinates(loc!.latitude, loc!.longitude))[0];

      setState(() {
        area = place.subLocality;
        pinCode = place.postalCode;
        state = place.administrativeArea;
        address = {
          place.subAdministrativeArea,
          place.name,
          place.street,
          place.subLocality,
          place.locality
        }.join(', ');
        city = place.locality;
      });
    } catch (e) {
      print(e);
    }
  }

  String? area;
  String? pinCode;
  String? state;
  String? address;
  String? city;

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: loc!,
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
            onTap: () {
              // print(widget.location.latitude);
            },
            child: const Text('Location')),
      ),
      body: SlidingUpPanel(
        panel: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 10,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('Metadata Details'),
              ],
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
          ),
          body: Container(
              // height: 00,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.timelapse),
                          title: Text(widget.time ?? 'Loading...'),
                          subtitle: const Text('Date & Time'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(widget.Model ?? 'Loading...'),
                          subtitle: const Text('Phone Model'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(area ?? 'Loading...'),
                          subtitle: const Text('Area'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(pinCode ?? 'Loading...'),
                          subtitle: const Text('Pincode'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(state ?? 'Loading...'),
                          subtitle: const Text('State'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(address ?? 'Loading...'),
                          subtitle: const Text('Address'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(city ?? 'Loading...'),
                          subtitle: const Text('City'),
                        ),
                      ]),
                ),
              )),
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: true,
          markers: <Marker>{
            Marker(
              markerId: const MarkerId('Emergency'),
              position:
                  LatLng(widget.location.latitude, widget.location.longitude),
              infoWindow: InfoWindow(title: 'MarkerId1 ${widget.location}'),
            ),
            // Marker(
            //   markerId: const MarkerId('Petrol Pump'),
            //   position: LatLng(
            //       widget.myLocation.latitude, widget.myLocation.longitude),
            //   infoWindow: const InfoWindow(title: 'MarkerId2'),
            // ),
          },
          // polylines: {
          //   Polyline(
          //     polylineId: const PolylineId('1'),
          //     points: widget.poyline
          //         .map((e) => LatLng(e[1], e[0]))
          //         .toList()
          //         .cast<LatLng>(),
          //     color: Colors.red,
          //   ),
          // },
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
