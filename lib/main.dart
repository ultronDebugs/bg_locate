import 'package:flutter/material.dart';
import 'package:background_locator_2/background_locator.dart';
// import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:location_permissions/location_permissions.dart';
import 'location_callback_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Location Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isRunning = false;
  String _locationData = 'No location data yet';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final permission = await LocationPermissions().checkPermissionStatus();
    if (permission != PermissionStatus.granted) {
      await LocationPermissions().requestPermissions();
    }
  }

  Future<void> _startLocationService() async {
    if (await _isLocationServiceRunning()) {
      return;
    }

    await BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: {'countInit': 1},
      disposeCallback: LocationCallbackHandler.disposeCallback,
      autoStop: false,
      iosSettings: IOSSettings(
        accuracy: LocationAccuracy.HIGH,
        distanceFilter: 0,
        stopWithTerminate: true,
      ),
      androidSettings: AndroidSettings(
        accuracy: LocationAccuracy.HIGH,
        interval: 5000,
        distanceFilter: 0,
        client: LocationClient.google,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'Location tracking',
          notificationTitle: 'Background location',
          notificationMsg: 'Track location in background',
          notificationBigMsg:
              'Background location is on to keep the app up-to-date with your location.',
        ),
      ),
    );

    setState(() {
      _isRunning = true;
    });
  }

  Future<void> _stopLocationService() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    setState(() {
      _isRunning = false;
    });
  }

  Future<bool> _isLocationServiceRunning() async {
    return await BackgroundLocator.isServiceRunning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Location Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Service Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isRunning ? 'Running' : 'Stopped',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isRunning ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Location:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(_locationData, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isRunning ? null : _startLocationService,
              child: Text('Start Location Service'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRunning ? _stopLocationService : null,
              child: Text('Stop Location Service'),
            ),
          ],
        ),
      ),
    );
  }
}
