import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../model/direccion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CajeroProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListarCompras = 'cajero/listar-registros';
  final String _urlListarEnCamno = 'cajero/listar-en-camino';
  final String _urlVerCostoPromocion = 'cajero/ver-costo-promocion';
  final String _urlCancelar = 'cajero/cancelar';
  final String _urlVer = 'cajero/ver';

  Future<CajeroModel> ver(dynamic idCompra) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlVer),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': idCompra.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return CajeroModel.fromJson(decodedResp['cajero']);
    }
    return null;
  }

  Future<CajeroModel> cancelar(CajeroModel cajeroModel, dynamic idClienteRecibe,
      dynamic idClienteEnvia, int envia) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCancelar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'envia': envia.toString(),
          'idClienteRecibe': idClienteRecibe.toString(),
          'idClienteEnvia': idClienteEnvia.toString(),
          'idCompra': cajeroModel.idCompra.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return CajeroModel.fromJson(decodedResp['cajero']);
    }
    return null;
  }

  Future<List<CajeroModel>> verCostoPromocion(int tipo,
      DireccionModel direccionModel, String agencias, String promociones,
      {DireccionModel direccionCliente}) async {
    var client = http.Client();
    List<CajeroModel> cajerosResponse = [];
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlVerCostoPromocion),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'tipo': tipo.toString(),
            'lt': direccionModel.lt.toString(),
            'lg': direccionModel.lg.toString(),
            'ltE': direccionCliente?.lt.toString(),
            'lgE': direccionCliente?.lg.toString(),
            'referencia': direccionModel.referencia.toString(),
            'agencias': agencias.replaceAll('[', '').replaceAll(']', ''),
            'promociones': promociones.replaceAll('[', '').replaceAll(']', ''),
          });

      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        double saldo = double.parse(decodedResp['saldo'].toString());
        double pay = double.parse(decodedResp['cash'].toString());
        for (var cajero in decodedResp['cajeros']) {
          CajeroModel _cajero = CajeroModel.fromJson(cajero);
          _cajero.saldoMoney = saldo;
          _cajero.pay = pay;
          cajerosResponse.add(_cajero);
        }
      }
      return cajerosResponse;
    } catch (err) {
      print('cajero_provider error: $err');
    } finally {
      client.close();
    }
    return null;
  }

  Future<List<CajeroModel>> listarEnCamino() async {
    var client = http.Client();
    List<CajeroModel> comprasResponse = [];
    try {
      final resp = await http.post(
          Uri.parse(Sistema.dominio + _urlListarEnCamno),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['cajeros']) {
          comprasResponse.add(CajeroModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cajero_provider error: $err');
    } finally {
      client.close();
    }
    return comprasResponse;
  }

  Future<List<CajeroModel>> listarCompras(int tipo, String fecha) async {
    var client = http.Client();
    List<CajeroModel> comprasResponse = [];
    try {
      final resp = await http.post(
          Uri.parse(Sistema.dominio + _urlListarCompras),
          headers: utils.headers,
          body: {
            'idCajero': _prefs.idCliente,
            'auth': _prefs.auth,
            'tipo': tipo.toString(),
            'fecha': fecha
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['cajeros']) {
          comprasResponse.add(CajeroModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cajero_provider error: $err');
    } finally {
      client.close();
    }
    return comprasResponse;
  }
}
