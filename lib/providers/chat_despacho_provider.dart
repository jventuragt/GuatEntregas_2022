import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/chat_despacho_model.dart';
import '../model/despacho_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as conf;
import '../utils/utils.dart' as utils;

class ChatDespachoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlObtener = 'chat-despacho/obtener';
  final String _urlEnviar = 'chat-despacho/enviar';
  final String _urlEstado = 'chat-despacho/estado';

  Future<List<ChatDespachoModel>> obtener(DespachoModel despachoModel) async {
    var client = http.Client();
    List<ChatDespachoModel> chatDespachosResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlObtener),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idDespacho': despachoModel.idDespacho.toString(),
            'idPool': despachoModel.idCliente.toString(),
            'auth': _prefs.auth,
          });
      if (resp.statusCode == 403) {
        _prefs.auth = '';
      }
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['chats']) {
          chatDespachosResponse.add(ChatDespachoModel.fromJson(item));
        }
      }
    } catch (err) {
      print('chat_despacho_provider error: $err');
    } finally {
      client.close();
    }
    return chatDespachosResponse;
  }

  enviar(ChatDespachoModel chatDespachoModel, DespachoModel despachoModel,
      Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEnviar),
        headers: utils.headers,
        body: {
          'idClienteEnvia': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'auth': _prefs.auth,
          'mensaje': chatDespachoModel.mensaje,
          'idClienteRecibe': (despachoModel.idConductor.toString() ==
                  _prefs.idCliente.toString())
              ? despachoModel.idCliente.toString()
              : despachoModel.idConductor.toString(),
          'envia': (despachoModel.idConductor.toString() ==
                  _prefs.idCliente.toString())
              ? conf.CHAT_ENVIA_CAJERO.toString()
              : conf.CHAT_ENVIA_CLIENTE.toString(),
          'tipo': chatDespachoModel.tipo.toString(),
          'valor': chatDespachoModel.valor.toString(),
          'idDespachoEstado': despachoModel.idDespachoEstado.toString()
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return response(decodedResp['id_chat'], decodedResp['chats']);
    }
    return response(0, 0);
  }

  estadoPush(dynamic idDespacho, dynamic idClienteEnvia,
      dynamic idClienteRecibe, dynamic estado) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEstado),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'idDespacho': idDespacho.toString(),
          'idClienteEnvia': idClienteEnvia.toString(),
          'idClienteRecibe': idClienteRecibe.toString(),
          'estado': estado.toString(),
        });

    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }
}
