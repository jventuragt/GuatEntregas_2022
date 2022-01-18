import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cliente_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class RegistroProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlRegistrar = 'registro/registrar';

  registrar(ClienteModel clienteModel, String codigoPais, String smn,
      Function response) async {
    await utils.getDeviceDetails();
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlRegistrar),
        headers: utils.headers,
        body: {
          'celular': clienteModel.celular.toString(),
          'correo': clienteModel.correo.toString(),
          'clave': clienteModel.clave.toString(),
          'nombres': clienteModel.nombres.toString(),
          'apellidos': clienteModel.apellidos.toString(),
          'cedula': clienteModel.cedula.toString(),
          'celularValidado': clienteModel.celularValidado.toString(),
          'correoValidado': clienteModel.correoValidado.toString(),
          'simCountryCode': _prefs.simCountryCode,
          'codigoPais': codigoPais,
          'token': _prefs.token,
          'smn': smn.toString(),
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      _prefs.auth = decodedResp['auth'];
      clienteModel = ClienteModel.fromJson(decodedResp['cliente']);
      _prefs.idCliente = clienteModel.idCliente.toString();
      _prefs.clienteModel = clienteModel;
      return response(1, clienteModel);
    }
    return response(0, decodedResp['error']);
  }
}
