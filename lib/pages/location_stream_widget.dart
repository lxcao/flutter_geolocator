import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_geolocator/models/point.dart';
import 'package:flutter_geolocator/models/trip.dart';
import 'package:flutter_geolocator/models/vehicle.dart';
import 'package:geolocator/geolocator.dart';

import '../common_widgets/placeholder_widget.dart';

class LocationStreamWidget extends StatefulWidget {
  @override
  State<LocationStreamWidget> createState() => LocationStreamState();
}

class LocationStreamState extends State<LocationStreamWidget> {
  StreamSubscription<Position> _positionStreamSubscription;
  List<Position> _positions = <Position>[];
  var _routeName = '';
  var _routeDescription = '';
  var _routeId = '';

  var _routeProfile = 'normal';
  var _vin = '1D4HR48N83F556450';

  var thisTrip;
  var thisStage;

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      const LocationOptions locationOptions = LocationOptions(
        accuracy: LocationAccuracy.best,
        //timeInterval: 3000,
        forceAndroidLocationManager: true,
        //distanceFilter: 10,
      );
      final Stream<Position> positionStream =
          Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream.listen(
          (Position position) => setState(() => _positions.add(position)));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
        _routeId = new DateTime.now().toString();
        thisTrip = new Trip(
          description: _routeDescription,
          name: _routeName,
          route_id: _routeId,
          profile: _routeProfile,
          vin: _vin,
          start: new List<double>(),
          end: new List<double>(),
          points: new List<List<double>>(),
        );
        print(jsonEncode(thisTrip));
      } else {
        _positionStreamSubscription.pause();
        thisTrip.start.add(_positions[0].latitude);
        thisTrip.start.add(_positions[0].longitude);
        thisTrip.end.add(_positions[_positions.length - 1].latitude);
        thisTrip.end.add(_positions[_positions.length - 1].longitude);
        _positions.forEach((position) {
          List<double> point = new List<double>();
          point.add(position.latitude);
          point.add(position.longitude);
          thisTrip.points.add(point);
        });
        _routeName = '';
        _routeDescription = '';
        _routeId = '';
        _positions.clear();
        print(jsonEncode(thisTrip));
      }
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeolocationStatus>(
        future: Geolocator().checkGeolocationPermissionStatus(),
        builder:
            (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == GeolocationStatus.denied) {
            return const PlaceholderWidget('Location services disabled',
                'Enable location services for this App using the device settings.');
          }

          return _buildListView();
        });
  }

  Widget _buildListView() {
    final nameController = TextEditingController();
    nameController.addListener(() {
      print('input route name is ${nameController.text}');
      _routeName = nameController.text;
    });
    final descController = TextEditingController();
    descController.addListener(() {
      print('input desc name is ${descController.text}');
      _routeDescription = descController.text;
    });
    final List<Widget> listItems = <Widget>[
      ListTile(
        title: _isListening()
            ? Text(_routeName)
            : TextField(
                controller: nameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    fillColor: Colors.blue.shade100,
                    filled: true,
                    hintText: "Route Name",
                    hintStyle: TextStyle(color: Colors.grey[400])),
              ),
      ),
      ListTile(
        title: _isListening()
            ? Text(_routeDescription)
            : TextField(
                controller: descController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    fillColor: Colors.blue.shade100,
                    filled: true,
                    hintText: "Descriptions",
                    hintStyle: TextStyle(color: Colors.grey[400])),
              ),
      ),
      ListTile(
        title: Text('routId: ' + _routeId),
      ),
      ListTile(
        title: Row(
          children: <Widget>[
            Text(
              'profile: ',
            ),
            SizedBox(
              width: 10.0,
            ),
            _isListening()
                ? Text(_routeProfile)
                : DropdownButton<String>(
                    value: _routeProfile,
                    items: <String>['normal', '002', '003', '004', '005']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String newValue) {
                      setState(() {
                        _routeProfile = newValue;
                      });
                    },
                  ),
          ],
        ),
      ),
      ListTile(
        title: Row(
          children: <Widget>[
            Text(
              'vin: ',
            ),
            SizedBox(
              width: 10.0,
            ),
            _isListening()
                ? Text(_vin)
                : DropdownButton<String>(
                    value: _vin,
                    items: vins.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String newValue) {
                      setState(
                        () {
                          _vin = newValue;
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
      ListTile(
        title: RaisedButton(
          child: _buildButtonText(),
          color: _determineButtonColor(),
          padding: const EdgeInsets.all(8.0),
          onPressed: _toggleListening,
        ),
      ),
    ];

    listItems.addAll(_positions
        .map((Position position) => PositionListItem(position))
        .toList());

    return ListView(
      children: listItems,
    );
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Widget _buildButtonText() {
    return Text(_isListening() ? 'Stop listening' : 'Start listening');
  }

  Color _determineButtonColor() {
    return _isListening() ? Colors.red : Colors.green;
  }
}

class PositionListItem extends StatefulWidget {
  const PositionListItem(this._position);

  final Position _position;

  @override
  State<PositionListItem> createState() => PositionListItemState(_position);
}

class PositionListItemState extends State<PositionListItem> {
  PositionListItemState(this._position);

  final Position _position;
  String _address = '';

  @override
  Widget build(BuildContext context) {
    final Row row = Row(
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Lat: ${_position.latitude}',
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              Text(
                'Lon: ${_position.longitude}',
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ]),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  _position.timestamp.toLocal().toString(),
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                )
              ]),
        ),
      ],
    );

    return ListTile(
      onTap: _onTap,
      title: row,
      subtitle: Text(_address),
    );
  }

  Future<void> _onTap() async {
    String address = 'unknown';
    final List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(_position.latitude, _position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      address = _buildAddressString(placemarks.first);
    }

    setState(() {
      _address = '$address';
    });
  }

  static String _buildAddressString(Placemark placemark) {
    final String name = placemark.name ?? '';
    final String city = placemark.locality ?? '';
    final String state = placemark.administrativeArea ?? '';
    final String country = placemark.country ?? '';
    final Position position = placemark.position;

    return '$name, $city, $state, $country\n$position';
  }
}
