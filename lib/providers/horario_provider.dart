import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/horario_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class HorarioProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListar = 'g/sucursal-horario/listar';

  final String _urlEditar = 'g/sucursal-horario/editar';

  Future<HorarioModel> editarHorario(HorarioModel horarioModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEditar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idSucursalHorario': horarioModel.idSucursalHorario.toString(),
          'idSucursal': horarioModel.idSucursal.toString(),
          'hora_desde': horarioModel.desde.toString(),
          'hora_hasta': horarioModel.hasta.toString(),
          'dia': horarioModel.dia.toString(),
          'tipo': horarioModel.tipo.toString(),
          'activo': horarioModel.activo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1)
      return HorarioModel.fromJson(decodedResp['horario']);
    return null;
  }

  Future<List<HorarioModel>> listarHorarios(dynamic idSucursal) async {
    var client = http.Client();
    List<HorarioModel> horarioesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idSucursal': idSucursal.toString(),
            'auth': _prefs.auth,
            'desde': '0',
            'cuantos': '50',
            'activo': '1',
            'bCriterio': '',
            'bIdUrbe': '0',
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['l']) {
          horarioesResponse.add(HorarioModel.fromJson(item));
        }
      }
    } catch (err) {
      print('horario_provider error: $err');
    } finally {
      client.close();
    }
    return horarioesResponse;
  }
}
