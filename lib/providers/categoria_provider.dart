import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/categoria_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CategoriaProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'categoria/listar';

  Future<List<CategoriaModel>> listar(dynamic idUrbe) async {
    var client = http.Client();
    List<CategoriaModel> categoriasResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idUrbe': idUrbe.toString(),
          });
      if (resp.statusCode == 403) {
        _prefs.auth = '';
      }
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['categorias']) {
          categoriasResponse.add(CategoriaModel.fromJson(item));
        }
      }
    } catch (err) {
      print('categoria_provider error: $err');
    } finally {
      client.close();
    }
    return categoriasResponse;
  }
}
