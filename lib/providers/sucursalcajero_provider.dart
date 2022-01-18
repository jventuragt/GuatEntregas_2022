import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/sucursalcajero_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class SucursalcajeroProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'g/sucursal-cajero/listar';

  final String _urlEditar = 'g/sucursal-cajero/editar';

  Future<SucursalcajeroModel> editarSucursalcajero(
      SucursalcajeroModel sucursalcajeroModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEditar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idSucursal': sucursalcajeroModel.idSucursal.toString(),
          'idCajero': sucursalcajeroModel.idCliente.toString(),
          'activo': sucursalcajeroModel.activo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1)
      return SucursalcajeroModel.fromJson(decodedResp['sucursalcajero']);
    return null;
  }

  Future<List<SucursalcajeroModel>> listarSucursalcajeros(
      dynamic idSucursal) async {
    var client = http.Client();
    List<SucursalcajeroModel> sucursalcajeroesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idSucursal': idSucursal.toString(),
            'auth': _prefs.auth,
            'desde': '0',
            'cuantos': '50',
            'activo': '-1',
            'bCriterio': '',
            'bIdUrbe': '0',
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['l']) {
          sucursalcajeroesResponse.add(SucursalcajeroModel.fromJson(item));
        }
      }
    } catch (err) {
      print('sucursalcajero_provider error: $err');
    } finally {
      client.close();
    }
    return sucursalcajeroesResponse;
  }
}
