import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/urbe_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class UrbeProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlLocalizar = 'urbe/localizar';

  localizar(double lg, double lt, Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlLocalizar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'lt': lt.toString(),
          'lg': lg.toString(),
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      UrbeModel urbeModel = UrbeModel.fromJson(decodedResp['urbe']);
      return response(1, urbeModel);
    }
    return response(0, decodedResp['error']);
  }
}
