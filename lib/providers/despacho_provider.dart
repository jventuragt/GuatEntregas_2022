import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/despacho_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class DespachoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final String _urlListarDepachos = 'despacho/listar-despachos';
  final String _urlIniciar = 'despacho/iniciar';
  final String _urlIRegistrar = 'despacho/registrar';
  final String _urlConfirmarRecogida = 'despacho/confirmar-recogida';
  final String _urlEntregarProducto = 'despacho/entregar-producto';
  final String _urlCancelar = 'despacho/cancelar';
  final String _urlReversar = 'despacho/reversar';
  final String _urlVer = 'despacho/ver';
  final String _urlCalificar = 'despacho/calificar';
  final String _urlMarcarLeido = 'despacho/marcar-leido';
  final String _urlConfirmarnNotificacion = 'despacho/confirmar-notificacion';

  Future<DespachoModel> reversar(DespachoModel despachoModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlReversar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  Future<DespachoModel> confirmarNoticicacion(
      DespachoModel despachoModel,
      dynamic idClienteRecibe,
      dynamic idClienteEnvia,
      int tipo,
      String preparandose,
      int tipoNotificacion) async {
    final resp = await http.post(
        Uri.parse(Sistema.dominio + _urlConfirmarnNotificacion),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'tipo': tipo.toString(),
          'idClienteRecibe': idClienteRecibe.toString(),
          'idClienteEnvia': idClienteEnvia.toString(),
          'idDespacho': despachoModel.idDespacho.toString(),
          'preparandose': preparandose,
          'tipoNotificacion': tipoNotificacion.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  Future<dynamic> registrar(DespachoModel despachoModel, String desde,
      String hasta, String detalle, String referencia) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlIRegistrar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': despachoModel.idCompra.toString(),
          'ltA': despachoModel.ltA.toString(),
          'lgA': despachoModel.lgA.toString(),
          'ltB': despachoModel.ltB.toString(),
          'lgB': despachoModel.lgB.toString(),
          'costo': despachoModel.costo.toString(),
          'costoEnvio': despachoModel.costoEnvio.toString(),
          'desde': desde.toString(),
          'hasta': hasta.toString(),
          'detalle': detalle.toString(),
          'referencia': referencia.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return decodedResp['idDespacho'];
    }
    return 0;
  }

  calificar(DespachoModel despachoModel, Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCalificar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'comentarioConductor': despachoModel.comentarioConductor.toString(),
          'calificacionConductor':
              despachoModel.calificacionConductor.toString(),
          'comentarioCliente': despachoModel.comentarioCliente.toString(),
          'calificacionCliente': despachoModel.calificacionCliente.toString(),
          'tipo': despachoModel.tipoUsuario().toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      DespachoModel despachoResponse =
          DespachoModel.fromJson(decodedResp['despacho']);
      return response(1, decodedResp['error'], despachoResponse);
    }
    return response(0, decodedResp['error'], null);
  }

  Future<bool> entregarProducto(DespachoModel despachoModel) async {
    final resp = await http.post(
        Uri.parse(Sistema.dominio + _urlEntregarProducto),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'idClienteRecibe': despachoModel.idCliente.toString(),
          'idClienteEnvia': despachoModel.idConductor.toString(),
          'comentarioConductor': despachoModel.comentarioConductor.toString(),
          'calificacionConductor':
              despachoModel.calificacionConductor.toString(),
          'comentarioCliente': despachoModel.comentarioCliente.toString(),
          'calificacionCliente': despachoModel.calificacionCliente.toString(),
          'tipo': despachoModel.tipoUsuario().toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<DespachoModel> confirmarRecogida(DespachoModel despachoModel,
      dynamic idClienteRecibe, dynamic idClienteEnvia, int tipo) async {
    final resp = await http.post(
        Uri.parse(Sistema.dominio + _urlConfirmarRecogida),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'tipo': tipo.toString(),
          'idClienteRecibe': idClienteRecibe.toString(),
          'idClienteEnvia': idClienteEnvia.toString(),
          'idDespacho': despachoModel.idDespacho.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  iniciar(DespachoModel despachoModel, Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlIniciar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return response(1, 'OK', DespachoModel.fromJson(decodedResp['despacho']));
    }
    return response(0, decodedResp['error'], null);
  }

  Future<bool> marcarLeido(DespachoModel despachoModel) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlMarcarLeido),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idDespacho': despachoModel.idDespacho.toString(),
          'tipo': despachoModel.tipoUsuario().toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

  Future<DespachoModel> ver(dynamic idDespacho, int tipo) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlVer),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'tipo': tipo.toString(),
          'idDespacho': idDespacho.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  Future<DespachoModel> cancelar(DespachoModel despachoModel,
      dynamic idClienteRecibe, dynamic idClienteEnvia, int tipo) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCancelar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'tipo': tipo.toString(),
          'idClienteRecibe': idClienteRecibe.toString(),
          'idClienteEnvia': idClienteEnvia.toString(),
          'idCompra': despachoModel.idCompra.toString(),
          'idDespacho': despachoModel.idDespacho.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return DespachoModel.fromJson(decodedResp['despacho']);
    }
    return null;
  }

  Future<List<DespachoModel>> listarCompras(int tipo, String fecha) async {
    var client = http.Client();
    List<DespachoModel> comprasResponse = [];
    try {
      final resp = await http.post(
          Uri.parse(Sistema.dominio + _urlListarDepachos),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'tipo': tipo.toString(),
            'fecha': fecha
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['despachos']) {
          comprasResponse.add(DespachoModel.fromJson(item));
        }
      }
    } catch (err) {
      print('despacho_provider error: $err');
    } finally {
      client.close();
    }
    return comprasResponse;
  }
}
