import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CompraClienteProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'compra/listar';

  Future<List<CajeroModel>> listarCompras(dynamic anio, dynamic mes) async {
    var client = http.Client();
    List<CajeroModel> comprasResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'anio': anio.toString(),
            'mes': mes.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['cajeros']) {
          comprasResponse.add(CajeroModel.fromJson(item));
        }
      }
    } catch (err) {
      print('compra_cliente_provider listarCompras error: $err');
    } finally {
      client.close();
    }
    return comprasResponse;
  }
}
