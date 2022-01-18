import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/reporte_model.dart';
import '../model/ventas_reporte_model.dart';
import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class ReporteProvider {
  final PreferenciasUsuario _prefs = PreferenciasUsuario();

  final String _urlComrpas = 'g/reporte/compras';
  final String _urlVentas = 'g/reporte/ventas';

  final f = new DateFormat('yyyy-MM-dd');

  Future<List<ReporteModel>> obtenerCompras(
      dynamic idAgencia, String fecha) async {
    List<ReporteModel> compras = [];
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlComrpas),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente.toString(),
            'auth': _prefs.auth,
            'idAgencia': idAgencia.toString(),
            'fecha': fecha == '' ? f.format(DateTime.now()) : fecha.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      int index = 0;
      if (decodedResp['estado'] == 1)
        for (var item in decodedResp['compras']) {
          ReporteModel obj = ReporteModel.fromJson(item);
          obj.number = index;
          index++;
          compras.add(obj);
        }
      return compras;
    } catch (error) {
      print('Error ReporteProvider compras');
    }
    return compras;
  }

  Future<List<VentasReporteModel>> obtenerVentas(
      dynamic idAgencia, String fecha) async {
    List<VentasReporteModel> ventas = [];
    try {
      final resp = await http.post(Uri.parse(Sistema.dominio + _urlVentas),
          headers: utils.headers,
          body: {
            'idCliente': _prefs.idCliente.toString(),
            'auth': _prefs.auth,
            'idAgencia': idAgencia.toString(),
            'fecha': fecha == '' ? f.format(DateTime.now()) : fecha.toString()
          });
      Map<String, dynamic> decodedResp = json.decode(resp.body);
      if (decodedResp['estado'] == 1)
        for (var item in decodedResp['ventas']) {
          ventas.add(VentasReporteModel.fromJson(item));
        }
      return ventas;
    } catch (error) {
      print('Error ReporteProvider compras');
    }
    return ventas;
  }
}
