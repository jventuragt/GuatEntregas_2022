import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/notificacion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class NotificacionProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'notificacion/listar';

  Future<List<NotificacionModel>> listarNotificaciones() async {
    var client = http.Client();
    List<NotificacionModel> notificacionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['notificaciones']) {
          notificacionesResponse.add(NotificacionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('notificacion_provider error: $err');
    } finally {
      client.close();
    }
    return notificacionesResponse;
  }
}
