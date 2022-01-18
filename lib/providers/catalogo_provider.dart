import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/catalogo_model.dart';
import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class CatalogoProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlListarAgencias = 'catalogo/listar-agencias';
  final String _urlListarPromociones = 'catalogo/listar-promociones';
  final String _urlVer = 'catalogo/ver';
  final String _urlLike = 'catalogo/like';
  final String _urlReferido = 'catalogo/referido';

  Future<bool> like(CatalogoModel catalogoModel,
      {bool isShare: false, dynamic idP: '0'}) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlLike),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idAgencia': catalogoModel.idAgencia.toString(),
            'like': catalogoModel.like.toString(),
            'share': isShare ? '1' : '0',
            'idP': idP.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  referido(CatalogoModel catalogoModel, {dynamic idP: '0'}) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlReferido),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idAgencia': catalogoModel.idAgencia.toString(),
            'idP': idP.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<CatalogoModel> ver(dynamic idCatalogo) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlVer),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idCatalogo': idCatalogo.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return CatalogoModel.fromJson(decodedResp['catalogo']);
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    } finally {
      client.close();
    }
    return null;
  }

  Future<List<CatalogoModel>> listarAgencias(
      int selectedIndex, dynamic idUrbe, int categoria, String criterio) async {
    var client = http.Client();
    List<CatalogoModel> catalogosResponse = [];
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlListarAgencias),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idUrbe': idUrbe.toString(),
            'selectedIndex': selectedIndex.toString(),
            'categoria': categoria.toString(),
            'criterio': criterio.toString(),
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        for (var item in decodedResp['catalogos']) {
          catalogosResponse.add(CatalogoModel.fromJson(item));
        }
      }
    } catch (err) {
      print('catalogo_provider error: $err');
    } finally {
      client.close();
    }
    return catalogosResponse;
  }

  bool _cargando = false;

  listarPromociones(dynamic idAgencia, dynamic alias, bool isClean, int pagina,
      dynamic idPromocion, Function response) async {
    var client = http.Client();
    List<PromocionModel> promocionesResponse = [];
    int total = 0;
    if (isClean || pagina == 0) {
      _cargando = false;
    }
    if (_cargando) return [];
    _cargando = true;
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlListarPromociones),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'pagina': pagina.toString(),
            'idAgencia': idAgencia.toString(),
            'perfil': _prefs.clienteModel.perfil.toString(),
            'alias': alias.toString(),
            'idPromocion': idPromocion.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        total = int.parse(decodedResp['total'].toString());
        for (var item in decodedResp['promociones']) {
          promocionesResponse.add(PromocionModel.fromJson(item));
        }
      }
    } catch (err) {
      print('promocion_provider error: $err');
    } finally {
      client.close();
      _cargando = false;
    }
    if (promocionesResponse.length <= 0) _cargando = true;
    return response(promocionesResponse, total);
  }
}
