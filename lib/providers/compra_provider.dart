import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cajero_model.dart';
import '../model/compra_promocion_model.dart';
import '../model/direccion_model.dart';
import '../model/factura_model.dart';
import '../model/promocion_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/conf.dart' as config;
import '../utils/utils.dart' as utils;

class CompraProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlVer = 'compra/ver';
  final String _urlMarcarLeido = 'compra/marcar-leido';
  final String _urlIniciar = 'compra/inciar';

  final String _urlCalificar = 'compra/calificar';
  final String _urlListarPromociones = 'compra/listar-promociones';

  Future<List<CompraPromocionModel>> listarCompraPromociones(
      dynamic idCompra) async {
    List<CompraPromocionModel> promocionesResponse = [];
    final resp = await http.post(
        Uri.parse(Sistema.dominio + _urlListarPromociones),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': idCompra.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      for (var item in decodedResp['promociones']) {
        promocionesResponse.add(CompraPromocionModel.fromJson(item));
      }
    }
    return promocionesResponse;
  }

  calificar(CajeroModel cajeroModel, int tipo, Function response) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlCalificar),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': cajeroModel.idCompra.toString(),
          'comentarioCajero': cajeroModel.comentarioCajero.toString(),
          'calificacionCajero': cajeroModel.calificacionCajero.toString(),
          'comentarioCliente': cajeroModel.comentarioCliente.toString(),
          'calificacionCliente': cajeroModel.calificacionCliente.toString(),
          'tipo': tipo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      CajeroModel cajeroResponse = CajeroModel.fromJson(decodedResp['cajero']);
      return response(1, decodedResp['error'], cajeroResponse);
    }
    return response(0, decodedResp['error'], null);
  }

  Future<bool> marcarLeido(CajeroModel cajeroModel, int tipo) async {
    final resp = await http.post(Uri.parse(Sistema.dominio + _urlMarcarLeido),
        headers: utils.headers,
        body: {
          'idCliente': _prefs.idCliente,
          'idCompra': cajeroModel.idCompra.toString(),
          'tipo': tipo.toString(),
          'auth': _prefs.auth,
        });
    Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp['estado'] == 1) {
      return true;
    }
    return false;
  }

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

  iniciar(int tipo, dynamic idCajero, dynamic idSucursal,
      DireccionModel direccionModel, dynamic costoEntrega, Function response,
      {DireccionModel direccionCliente,
      List<PromocionModel> promociones,
      CajeroModel cajero,
      costo,
      costoTotal,
      FacturaModel facturaModel}) async {
    if (facturaModel == null) facturaModel = FacturaModel();

    var client = http.Client();
    try {
      final resp = await client.post(Uri.parse(Sistema.dominio + _urlIniciar),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente,
            'idCajero': idCajero.toString(),
            'transaccion': cajero?.transaccion.toString(),
            'idHashtag': cajero?.idHashtag.toString(),
            'descuento': cajero?.descuento.toString(),
            'aCobrar': cajero?.aCobrar?.toStringAsFixed(2),
            'descontado': cajero?.descontado?.toStringAsFixed(2),
            'cash': cajero?.cashConsumido()?.toStringAsFixed(2),
            'idCash': cajero?.idCash?.toString(),
            'idCupon': cajero?.cardModel?.idCupon.toString(),
            'idFormaPago': cajero?.cardModel?.idFormaPago.toString(),
            'cupon': cajero?.cardModel?.cupon.toString(),
            'credito': cajero?.credito.toString(),
            'creditoProducto': cajero?.creditoProducto.toString(),
            'creditoEnvio': cajero?.creditoEnvio.toString(),
            'token': cajero?.cardModel?.token.toString(),
            'type': cajero?.cardModel?.type.toString(),
            'idSucursal': idSucursal.toString(),
            'idDireccion': direccionModel.idDireccion.toString(),
            'referencia': direccionModel.referencia.toString(),
            'lt': direccionModel.lt.toString(),
            'lg': direccionModel.lg.toString(),
            'costoEntrega': costoEntrega.toString(),
            'tipo': tipo.toString(),
            'ltE': direccionCliente?.lt.toString(),
            'lgE': direccionCliente?.lg.toString(),
            'contactoE': direccionCliente?.alias.toString(),
            'auth': _prefs.auth,
            'idFactura': facturaModel.idFactura.toString(),
            'factura': facturaModel.toString(),
            'promociones': json.encode(promociones),
            'costo': costo.toStringAsFixed(2),
            'costoTotal': costoTotal.toStringAsFixed(2),
          });

      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1)
        return response(1, 'Solicitud iniciada',
            CajeroModel.fromJson(decodedResp['cajero']));
      return response(decodedResp['estado'], decodedResp['error'], null);
    } catch (err) {
      print('compra_provider error: $err');
    } finally {
      client.close();
    }
    return response(-100, config.MENSAJE_INTERNET, null);
  }
}
