import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/factura_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class FacturaProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'factura/listar';
  final String _urlVer = 'factura/ver';
  final String _urlCrear = 'factura/crear';
  final String _urlEditar = 'factura/editar';
  final String _urlEliminar = 'factura/eliminar';
  final String _urlOrnernar = 'factura/ordenar';

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
      print('factura_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<bool> eliminarFactura(FacturaModel facturaModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEliminar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idFactura': facturaModel.idFactura.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<bool> editarFactura(FacturaModel facturaModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEditar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idFactura': facturaModel.idFactura.toString(),
          'dni': facturaModel.dni.toString(),
          'direccion': facturaModel.direccion.toString(),
          'numero': facturaModel.numero.toString(),
          'nombres': facturaModel.nombres.toString(),
          'correo': facturaModel.correo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<FacturaModel> crearFactura(FacturaModel facturaModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCrear),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'dni': facturaModel.dni.toString(),
          'direccion': facturaModel.direccion.toString(),
          'numero': facturaModel.numero.toString(),
          'nombres': facturaModel.nombres.toString(),
          'correo': facturaModel.correo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      facturaModel.idFactura = decodedResp['idFactura'];
      return facturaModel;
    }
    return null;
  }

  Future<FacturaModel> ver(dynamic idClienteFactura) async {
    var client = http.Client();

    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idClienteFactura': idClienteFactura.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return FacturaModel.fromJson(decodedResp['factura']);
      }
    } catch (err) {
      print('factura_provider error: $err');
    } finally {
      client.close();
    }
    return null;
  }

  Future<List<FacturaModel>> listarFacturaes() async {
    var client = http.Client();
    List<FacturaModel> facturaesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['facturaes']) {
          facturaesResponse.add(FacturaModel.fromJson(item));
        }
      }
    } catch (err) {
      print('factura_provider error: $err');
    } finally {
      client.close();
    }
    return facturaesResponse;
  }
}
