import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cliente_model.dart';
import '../model/direccion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class DireccionProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'direccion/listar';
  final String _urlCrear = 'direccion/crear';
  final String _urlEditar = 'direccion/editar';
  final String _urlEliminar = 'direccion/eliminar';
  final String _urlOrnernar = 'direccion/ordenar';

  Future<bool> ordenar(String ids) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlOrnernar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'ids': ids.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) return true;
    } catch (err) {
      print('direccion_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<bool> eliminarDireccion(DireccionModel direccionModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDireccion': direccionModel.idDireccion.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<bool> editarDireccion(DireccionModel direccionModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEditar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDireccion': direccionModel.idDireccion.toString(),
          'referencia': direccionModel.referencia.toString(),
          'alias': direccionModel.alias.toString(),
          'lt': direccionModel.lt.toString(),
          'lg': direccionModel.lg.toString(),
          'idUrbe': direccionModel.idUrbe.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<int> crearDireccion(DireccionModel direccionModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCrear),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'alias': direccionModel.alias.toString(),
          'referencia': direccionModel.referencia.toString(),
          'lt': direccionModel.lt.toString(),
          'lg': direccionModel.lg.toString(),
          'idUrbe': direccionModel.idUrbe.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      ClienteModel clienteModel = _prefs.clienteModel;
      clienteModel.direcciones = 1;
      _prefs.clienteModel = clienteModel;
      return decodedResp['idDireccion'];
    }
    return 0;
  }

  Future<List<DireccionModel>> listarDirecciones() async {
    var client = http.Client();
    List<DireccionModel> direccionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['direcciones']) {
          direccionesResponse.add(DireccionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('direccion_provider error: $err');
    } finally {
      client.close();
    }
    return direccionesResponse;
  }
}
