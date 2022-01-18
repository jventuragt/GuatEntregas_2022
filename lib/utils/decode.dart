import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;

List<gmf.LatLng> decodePolylinePoints(List encoded, rutaModel) {
  List<List<double>> tR = [];
  List<gmf.LatLng> points = [];
  for (int i = 0; i < encoded.length; i++) {
    List<String> a = encoded[i].toString().split(',');
    gmf.LatLng p = new gmf.LatLng(double.parse(a[0]), double.parse(a[1]));
    tR.add([p.latitude, p.longitude]);
    points.add(p);
  }
  if (rutaModel != null) rutaModel.tR = tR;
  return points;
}

List<gmf.LatLng> decodePolylineString(String encoded, rutaModel) {
  List<List<double>> tR = [];
  List<gmf.LatLng> points = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    gmf.LatLng p = new gmf.LatLng(lat / 1E5, lng / 1E5);
    tR.add([p.latitude, p.longitude]);
    points.add(p);
  }
  if (rutaModel != null) rutaModel.tR = tR;
  return points;
}

List<gmf.LatLng> decodePolyline(dynamic encoded, rutaModel) {
  if (encoded is List) return decodePolylinePoints(encoded, rutaModel);
  return decodePolylineString(encoded, rutaModel);
}

rad(x) {
  return x * math.pi / 180;
}

getKilometros(lat1, lon1, lat2, lon2) {
  var R = 6378.137; //Radio de la tierra en km
  var dLat = rad(lat2 - lat1);
  var dLong = rad(lon2 - lon1);
  var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.sin(dLong / 2) *
          math.sin(dLong / 2);
  var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  var d = R * c * 1000; //Por mil para enviar en metros
  return d.toDouble(); //Retorna tres decimales
}
