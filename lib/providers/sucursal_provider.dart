import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/sucursal_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class SucursalProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'g/sucursal/listar';
  final String _urlBuscar = 'g/sucursal/buscar';
  final String _urlEditar = 'g/sucursal/editar';

  Future<bool> editarSucursal(SucursalModel sucursalModel) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlEditar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idSucursal': sucursalModel.idSucursal.toString(),
            'sucursal': sucursalModel.sucursal.toString(),
            'direccion': sucursalModel.direccion.toString(),
            'lt': sucursalModel.lt.toString(),
            'lg': sucursalModel.lg.toString(),
            'observacion': sucursalModel.observacion.toString(),
            'contacto': sucursalModel.contacto.toString(),
            'mail': sucursalModel.mail.toString(),
            'activo': sucursalModel.activo.toString(),
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('sucursal_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<List<SucursalModel>> listarSucursales(dynamic idAgencia) async {
    var client = http.Client();
    List<SucursalModel> sucursalesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idAgencia': idAgencia.toString(),
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
          sucursalesResponse.add(SucursalModel.fromJson(item));
        }
      }
    } catch (err) {
      print('sucursal_provider error: $err');
    } finally {
      client.close();
    }
    return sucursalesResponse;
  }

  Future<List<SucursalModel>> buscarSucursales(dynamic criterio) async {
    var client = http.Client();
    List<SucursalModel> sucursalesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlBuscar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'bCriterio': criterio.toString(),
            'auth': _prefs.auth,
            'desde': '0',
            'cuantos': '50',
            'activo': '-1',
            'bIdUrbe': '0',
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['l']) {
          sucursalesResponse.add(SucursalModel.fromJson(item));
        }
      }
    } catch (err) {
      print('sucursal_provider error: $err');
    } finally {
      client.close();
    }
    return sucursalesResponse;
  }
}
