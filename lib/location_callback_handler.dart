import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';

class LocationCallbackHandler {
  static const String _isolateName = 'LocatorIsolate';
  static const String _notificationTitle = 'receiving location';
  static const String _notificationMsg = 'location in background';
  static int _count = 0;

  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    print('LocationCallbackHandler: initCallback called');

    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      }
      if (tmpCount is String) {
        _count = int.parse(tmpCount);
      }
      if (tmpCount is int) {
        _count = tmpCount;
      }
    }

    print('LocationCallbackHandler: _count initialized to $_count');

    final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(null);
  }

  static Future<void> disposeCallback() async {
    print('LocationCallbackHandler: disposeCallback called');
    final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(null);
  }

  static Future<void> callback(LocationDto locationDto) async {
    print('LocationCallbackHandler: callback called');
    print(
      'Location received: Lat: ${locationDto.latitude}, Lng: ${locationDto.longitude}',
    );
    print('Accuracy: ${locationDto.accuracy}');
    print('Altitude: ${locationDto.altitude}');
    // print('Bearing: ${locationDto.bearing}');
    print('Speed: ${locationDto.speed}');
    print(
      'Time: ${DateTime.fromMillisecondsSinceEpoch(locationDto.time.toInt())}',
    );
    print('Provider: ${locationDto.provider}');
    // print('Is Mock: ${locationDto.isMock}');
    print('---');

    _count++;

    final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto);
  }

  static void notificationCallback() {
    print('LocationCallbackHandler: notificationCallback called');
  }
}
