import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/agencia_model.dart';
import '../model/direccion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/utils.dart' as utils;

class AgenciaProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'g/agencia/listar';
  final String _urlRegistrar = 'g/agencia/registro';
  final String _urlListarPreRegistro = 'g/agencia/listar-pre-registro';

  final String _urlPreRegistro = 'agencia/pre-registro';

  registrar(AgenciaModel agenciaModel, Function response) async {
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlRegistrar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'contacto': agenciaModel.contacto.toString(),
            'idUrbe': agenciaModel.idUrbe.toString(),
            'lt': agenciaModel.lt.toString(),
            'lg': agenciaModel.lg.toString(),
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return response(1, decodedResp['error']);
      } else {
        return response(0, decodedResp['error']);
      }
    } catch (err) {
      print('Error agenca');
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  preRegistro(AgenciaModel agenciaModel, DireccionModel direccionModel,
      Function response) async {
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlPreRegistro),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'agencia': agenciaModel.agencia.toString(),
            'activo': agenciaModel.activo.toString(),
            'observacion': agenciaModel.observacion.toString(),
            'contacto': agenciaModel.contacto.toString(),
            'mail': agenciaModel.mail.toString(),
            'direccion': direccionModel.alias.toString(),
            'idUrbe': direccionModel.idUrbe.toString(),
            'lt': direccionModel.lt.toString(),
            'lg': direccionModel.lg.toString(),
            'auth': _prefs.auth,
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return response(1, decodedResp['error']);
      } else {
        return response(0, decodedResp['error']);
      }
    } catch (err) {
      print('Error agenca');
    }
    return response(0, config.MENSAJE_INTERNET);
  }

  Future<List<AgenciaModel>> listarPreRegistros(selectedIndex) async {
    var client = http.Client();
    List<AgenciaModel> agenciaesResponse = [];
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlListarPreRegistro),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'tipo': selectedIndex.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['agencias']) {
          agenciaesResponse.add(AgenciaModel.fromJson(item));
        }
      }
    } catch (err) {
      print('agencia_provider error: $err');
    } finally {
      client.close();
    }
    return agenciaesResponse;
  }

  Future<List<AgenciaModel>> listarAgencias({String bCriterio: ''}) async {
    var client = http.Client();
    List<AgenciaModel> agenciaesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'desde': '0',
            'cuantos': '50',
            'activo': '-1',
            'bCriterio': bCriterio.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['l']) {
          agenciaesResponse.add(AgenciaModel.fromJson(item));
        }
      }
    } catch (err) {
      print('agencia_provider error: $err');
    } finally {
      client.close();
    }
    return agenciaesResponse;
  }
}
