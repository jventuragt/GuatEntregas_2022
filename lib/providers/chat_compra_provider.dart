import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../model/chat_compra_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class ChatCompraProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlObtener = 'chat-compra/obtener';
  final String _urlEnviar = 'chat-compra/enviar';
  final String _urlEstado = 'chat-compra/estado';

  Future<List<ChatCompraModel>> obtener(dynamic idCompra) async {
    var client = http.Client();
    List<ChatCompraModel> chatsResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlObtener),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idCompra': idCompra.toString(),
            'auth': _prefs.auth,
          });
      if (resp.statusCode == 403) {
        _prefs.auth = '';
      }
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['chats']) {
          chatsResponse.add(ChatCompraModel.fromJson(item));
        }
      }
    } catch (err) {
      print('chat_compra_provider error: $err');
    } finally {
      client.close();
    }
    return chatsResponse;
  }

  enviar(ChatCompraModel chatCompraModel, CajeroModel cajeroModel,
      Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEnviar),
        headers: utils.headers,
        body: {
          'idClienteEnvia': _prefs.idCliente,
          'idCompra': chatCompraModel.idCompra.toString(),
          'auth': _prefs.auth,
          'mensaje': chatCompraModel.mensaje,
          'idClienteRecibe': chatCompraModel.idClienteRecibe.toString(),
          'envia': chatCompraModel.envia.toString(),
          'tipo': chatCompraModel.tipo.toString(),
          'valor': chatCompraModel.valor.toString(),
          'idCompraEstado': cajeroModel.idCompraEstado.toString()
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return response(decodedResp['id_chat'], decodedResp['chats']);
    }
    return response(0, 0);
  }

  estadoPush(dynamic idCompra, dynamic idClienteEnvia, dynamic idClienteRecibe,
      dynamic estado) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlEstado),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'auth': _prefs.auth,
          'idCompra': idCompra.toString(),
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
