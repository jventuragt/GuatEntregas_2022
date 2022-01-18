import 'dart:convert';

import 'package:http/http.dart' as http;

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class MapaProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlLugaresCercanos = 'mapa/lugares-cercanos';
  final String _urlUrl = 'mapa/localizar-url';
  final String _urlLocalizar = 'mapa/localizar';
  final String _urlTrazar = 'mapa/trazar';

  trazar(dynamic ltO, dynamic lgO, dynamic ltD, dynamic lgD, String waypoints,
      Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlTrazar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'ltO': ltO.toString(),
          'lgO': lgO.toString(),
          'ltD': ltD.toString(),
          'lgD': lgD.toString(),
          'waypoints': waypoints,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    return response(decodedResp);
  }

  Future<List> lugaresCercanos(double lt, double lg, dynamic criterio) async {
    if (criterio.length <= 2) return [];
    try {
      final resp = await http.post(
          Uri.parse(Sistema.dominio + _urlLugaresCercanos),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'lt': lt.toStringAsFixed(5).toString(),
            'lg': lg.toStringAsFixed(5).toString(),
            'criterio': criterio.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      return decodedResp['lL'];
    } catch (err) {
      print('XD');
    }
    return [];
  }

  url(String url, Function callback) async {
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlUrl),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'url': url,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1)
        return callback(1, decodedResp['lt'], decodedResp['lg']);
    } catch (err) {
      print('=(');
    }
    return callback(-1, 0.0, 0.0);
  }

  Future localizar(dynamic placeId, String main, String secondary) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlLocalizar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'placeId': placeId.toString(),
          'main': main,
          'secondary': secondary,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    return decodedResp['p'];
  }
}
