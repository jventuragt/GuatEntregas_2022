import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../preference/shared_preferences.dart';
import '../providers/cliente_provider.dart';
import '../sistema.dart';

class Rastreo {
  static Rastreo _instancia;

  Rastreo._internal();

  final _prefs = PreferenciasUsuario();
  final _clienteProvider = ClienteProvider();
  Location location;

  factory Rastreo() {
    if (_instancia == null) {
      _instancia = Rastreo._internal();
      _instancia.init();
    }
    return _instancia;
  }

  init() {
    location = Location();
  }

  rad(x) {
    return x * Math.pi / 180;
  }

  getKilometros(lat1, lon1, lat2, lon2) {
    var R = 6378.137; //Radio de la tierra en km
    var dLat = rad(lat2 - lat1);
    var dLong = rad(lon2 - lon1);
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(rad(lat1)) *
            Math.cos(rad(lat2)) *
            Math.sin(dLong / 2) *
            Math.sin(dLong / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    return d;
  }

  Future<bool> notificarUbicacion(
      {bool isEvaluar: false, double lt, double lg}) async {
    var location = await Location().getLocation();
    if (location == null) return false;
    if (!isEvaluar) {
      _clienteProvider.enviarRastreo(location.latitude, location.longitude);
      return true;
    }
    double kl =
        getKilometros(location.latitude, location.longitude, lt, lg) * 1000;
    int metros = kl.toInt();
    if (metros <= 80) return true;
    _clienteProvider.enviarRastreo(location.latitude, location.longitude);
    return false;
  }

  Future<bool> activarGps() async {
    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      location.requestService();
      return false;
    }
    return true;
  }

  Future localizar() async {
    double lt = Sistema.lt, lg = Sistema.lg;

    Location location = new Location();
    LocationData _locationData;
    try {
      _locationData =
          await location.getLocation().timeout(Duration(seconds: 10));
      return [_locationData.latitude, _locationData.longitude];
    } catch (err) {
      print('Error timeout 1');
      try {
        _locationData =
            await location.getLocation().timeout(Duration(seconds: 15));
        return [_locationData.latitude, _locationData.longitude];
      } catch (err) {
        print('Error timeout 2');
      }
    }
    return [lt, lg];
  }

  Future<bool> optimizadoCheck() async {
    _prefs.optimizado = true;
    return _prefs.optimizado;
  }

  Future<bool> start(context, {bool isRadar: false}) async {
    print('CALL START');
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    location.changeNotificationOptions(
        channelName: "Curiosity",
        iconName: "@mipmap/ic_launcher",
        color: Colors.white,
        title: 'Rastreando',
        subtitle: "Receptando solicitudes",
        description: "Receptando solicitudes",
        onTapBringToFront: true);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    // await location.enableBackgroundMode(enable: true);
    await location.changeSettings(interval: 10000, distanceFilter: 20);
    OnLocationChanged(location);
    _clienteProvider.rastrear(true);
    _prefs.rastrear = true;
    return _prefs.rastrear;
  }

  Future stop() async {
    print('CALL STOP');
    location.enableBackgroundMode(enable: false);
    await _clienteProvider.rastrear(false);
    _prefs.rastrear = false;
    return _prefs.rastrear;
  }

  bool isRastrear() {
    return _prefs.rastrear;
  }
}

class OnLocationChanged {
  static OnLocationChanged _instancia;
  final Location location;

  OnLocationChanged._internal(this.location);

  final _prefs = PreferenciasUsuario();
  final _clienteProvider = ClienteProvider();

  factory OnLocationChanged(Location location) {
    if (_instancia == null) {
      _instancia = OnLocationChanged._internal(location);
      _instancia.init();
    }
    return _instancia;
  }

  init() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (_prefs.rastrear)
        _clienteProvider.enviarRastreo(
            currentLocation.latitude, currentLocation.longitude);
    });
  }
}
