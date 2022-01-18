import 'dart:convert';

import 'package:http/http.dart' as http;

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/utils.dart' as utils;

class ContactoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlEnviar = 'contacto/enviar';

  enviar(dynamic contacto, dynamic calificacion, Function response) async {
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlEnviar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente.toString(),
            'auth': _prefs.auth,
            'calificacion': calificacion.toString(),
            'contacto': contacto.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return response(1, decodedResp['error']);
      return response(0, decodedResp['error']);
    } catch (error) {
      return response(0, config.MENSAJE_INTERNET);
    }
  }
}
