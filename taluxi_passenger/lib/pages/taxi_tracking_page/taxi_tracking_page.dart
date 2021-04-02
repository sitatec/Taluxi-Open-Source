import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi_common/taluxi_common.dart';

import 'taxi_tracker_page_widgets.dart';

// ignore: must_be_immutable
class TaxiTrackingPage extends StatefulWidget {
  static final CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  final Map<String, Coordinates> dataOfDriverToTrack;
  String _idOfDriverToTrack;
  CameraPosition _initialCameraPosition;

  TaxiTrackingPage(this.dataOfDriverToTrack) {
    _idOfDriverToTrack = dataOfDriverToTrack.keys.first;
    final _coordinatesOfDriverToTrack = dataOfDriverToTrack[_idOfDriverToTrack];
    _initialCameraPosition = CameraPosition(
      target: LatLng(
        _coordinatesOfDriverToTrack.latitude,
        _coordinatesOfDriverToTrack.longitude,
      ),
      zoom: 15.4746,
    );
  }

  @override
  _TaxiTrackingPageState createState() => _TaxiTrackingPageState();
}

// TODO refactoring .
class _TaxiTrackingPageState extends State<TaxiTrackingPage> {
  Completer<GoogleMapController> _mapController = Completer();
  var _mapOpacity = 0.0;
  Timer timer;
  final _markers = <Marker>{};
  final _deviceLocationHandler = DeviceLocationHandler.instance;
  RealTimeLocation _realTimeLocation;

  @override
  void initState() {
    super.initState();
    _initializesLocationServices();
    _markers.add(Marker(
      markerId: MarkerId('driver'),
      position: widget._initialCameraPosition.target,
      infoWindow: InfoWindow(title: "Driver"),
    ));
    timer = Timer(
      Duration(milliseconds: 500),
      () => setState(() => _mapOpacity = 1),
    );
  }

  Future<void> _initializesLocationServices() async {
    _realTimeLocation = Provider.of<RealTimeLocation>(context, listen: false);
    await _realTimeLocation.initialize(currentUserId: 'test');
    await _deviceLocationHandler.initialize(requireBackground: true);
    _deviceLocationHandler
        .getCoordinatesStream(distanceFilterInMeter: 5)
        .listen(_currentUserLocationTraker);
    _realTimeLocation
        .startLocationTracking(widget._idOfDriverToTrack)
        .listen(_driverLocationTraker);
  }

  void _currentUserLocationTraker(Coordinates coordinates) {
    setState(
      () => _markers.add(Marker(
        markerId: MarkerId('currentUser'),
        position: LatLng(coordinates.latitude, coordinates.longitude),
        infoWindow: InfoWindow(title: "currentUser"),
      )),
    );
  }

  void _driverLocationTraker(Coordinates coordinates) {
    setState(
      () => _markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(title: "driver"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: CustomDrower(),
      body: Builder(
        builder: (context) => Container(
          child: Stack(children: [
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _mapOpacity,
              child: GoogleMap(
                markers: _markers,
                padding: EdgeInsets.only(bottom: 65),
                mapType: MapType.normal,
                initialCameraPosition: widget._initialCameraPosition,
                onMapCreated: (GoogleMapController controller) async {
                  _mapController.complete(controller);
                },
              ),
            ),
            _backButton(context),
            _menuButton(context),
            Align(
              alignment: Alignment.bottomCenter,
              child: CurvedNavigationBar(
                height: 65,
                color: Color(0xFFFFA715),
                backgroundColor: Colors.transparent,
                //buttonBackgroundColor: Colors.white,
                items: <Widget>[
                  Icon(
                    Icons.my_location,
                    size: 25,
                    color: Colors.white,
                  ),
                  Image.asset("assets/images/taxi-sign.png",
                      width: 25, height: 25)
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Positioned _menuButton(BuildContext context) {
    return Positioned(
      right: 10,
      top: 53,
      child: InkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              gradient: mainLinearGradient,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Positioned _backButton(BuildContext context) {
    return Positioned(
      left: 10,
      top: 53,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              gradient: mainLinearGradient,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(TaxiTrackingPage._kLake));
  }
}
