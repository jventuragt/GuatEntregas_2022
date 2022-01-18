import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cliente_model.dart';
import '../model/factura_model.dart';
import '../model/tarjeta_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/utils.dart' as utils;

class VentasProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlVer = 'g/ventas/ver';
  final String _urlPaquete = 'g/ventas/tarjetas';
  final String _urlComprar = 'g/ventas/comprar';

  comprar(dynamic idTarjeta, dynamic idClienteRecargar, String creditoAconsumir,
      String recibo, FacturaModel factura, Function response) async {
    var client = http.Client();
    ClienteModel clienteModel;
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlComprar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idTarjeta': idTarjeta.toString(),
            'idClienteRecargar': idClienteRecargar.toString(),
            'credito': creditoAconsumir,
            'recaudado': recibo,
            'factura': factura.toJson().toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      print(decodedResp);
      if (decodedResp['estado'] == 1) {
        clienteModel = ClienteModel.fromJson(decodedResp['cliente']);
        return response(1, decodedResp['error'], clienteModel);
      }
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET, clienteModel);
  }

  Future<List<TarjetaModel>> tarjetas() async {
    var client = http.Client();
    List<TarjetaModel> tarjetasResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlPaquete),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['tarjetas']) {
          tarjetasResponse.add(TarjetaModel.fromJson(item));
        }
      }
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return tarjetasResponse;
  }

  ver(String celular, String token, Function response) async {
    var client = http.Client();
    ClienteModel clienteModel;
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'celular': celular,
            'token': token
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp['estado'] == 1) {
        clienteModel = ClienteModel.fromJson(decodedResp['cliente']);
        return response(1, decodedResp['error'], clienteModel);
      }
    } catch (err) {
      print('cliente_provider error: $err');
    } finally {
      client.close();
    }
    return response(0, config.MENSAJE_INTERNET, clienteModel);
  }
}
