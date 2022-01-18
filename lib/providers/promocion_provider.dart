import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class PromocionProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlSubirImagen = 'g/promocion/subir';
  final String _urlListar = 'promocion/listar';
  final String _urlEditar = 'g/promocion/editar';
  final String _urlEditarSubProductos = 'g/promocion/editar-sub-productos';

  bool _cargando = false;
  int _pagina = 0;

  Future<bool> subirArchivoMobil(io.File imagen, dynamic nombreImagen,
      String id, dynamic idagencia, dynamic idurbe, int targetWidth) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(imagen.path);
    io.File compressedFile = await FlutterNativeImage.compressImage(imagen.path,
        targetWidth: targetWidth,
        targetHeight:
            (properties.height * targetWidth / properties.width).round());
    try {
      final mimeType = mime(compressedFile.path).split('/'); //image/jpeg
      FormData formData = new FormData.fromMap({
        "promocion": await MultipartFile.fromFile(compressedFile.path,
            contentType: MediaType(mimeType[0], mimeType[1]))
      });
      var headers = utils.headers;
      headers['archivo'] = nombreImagen.toString();
      headers['idcliente'] = _prefs.idCliente.toString();
      headers['idagencia'] = idagencia.toString();
      headers['idurbe'] = idurbe.toString();
      headers['id'] = id.toString();
      await Dio().post(
        Sistema.dominio + _urlSubirImagen,
        data: formData,
        options: Options(headers: headers),
      );
      return false;
    } catch (err) {
      print('promocion_provider error: $err');
    }
    return false;
  }

  Future<bool> subirArchivoWeb(
      List<int> value, String nombreImagen, String id) async {
    try {
      FormData formData = FormData.fromMap({
        "promocion": MultipartFile.fromBytes(value, filename: nombreImagen),
      });
      var headers = utils.headers;
      headers['archivo'] = nombreImagen.toString();
      headers['id'] = id.toString();
      await Dio().post(
        Sistema.dominio + _urlSubirImagen,
        data: formData,
        options: Options(headers: headers),
      );
      return false;
    } catch (err) {
      print('promocion_provider error: $err');
    }
    return false;
  }

  Future<List<PromocionModel>> listarPromociones(
      String idUrbe, bool isClean, String criterio, int categoria) async {
    if (isClean) {
      _pagina = 0;
      _cargando = false;
    }

    if (_cargando) return [];
    _cargando = true;
    var client = http.Client();
    List<PromocionModel> promocionesResponse = [];
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlListar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'pagina': _pagina.toString(),
            'idUrbe': idUrbe.toString(),
            'criterio': criterio,
            'categoria': categoria.toString(),
          });
      _pagina++;
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
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
    return promocionesResponse;
  }

  Future<bool> editar(PromocionModel promocion) async {
    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlEditar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idAgencia': promocion.idAgencia.toString(),
            'idUrbe': promocion.idUrbe.toString(),
            'incentivo': promocion.incentivo.toString(),
            'producto': promocion.producto.toString(),
            'descripcion': promocion.descripcion.toString(),
            'precio': promocion.precio.toString(),
            'minimo': promocion.minimo.toString(),
            'maximo': promocion.maximo.toString(),
            'inventario': promocion.inventario.toString(),
            'activo': promocion.activo.toString(),
            'visible': promocion.visible.toString(),
            'promocion': promocion.promocion.toString(),
            'idPromocion': promocion.idPromocion.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('promocion_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }

  Future<bool> editarSubProductos(PromocionModel promocion) async {
    var client = http.Client();
    try {
      final resp = await client.post(
          Uri.parse(Sistema.dominio + _urlEditarSubProductos),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'auth': _prefs.auth,
            'idPromocion': promocion.idPromocion.toString(),
            'productos': promocion.productos.toJson().toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1) {
        return true;
      }
    } catch (err) {
      print('promocion_provider error: $err');
    } finally {
      client.close();
    }
    return false;
  }
}
