import 'dart:async';

import '../model/reporte_model.dart';
import '../model/ventas_reporte_model.dart';
import '../providers/reporte_provider.dart';

class ReporteBloc {
  final ReporteProvider _reporteProvider = ReporteProvider();

  static ReporteBloc _instancia;

  ReporteBloc._internal();

  factory ReporteBloc() {
    if (_instancia == null) {
      _instancia = ReporteBloc._internal();
    }
    return _instancia;
  }

  final comprasStreamController =
      StreamController<List<ReporteModel>>.broadcast();

  Function(List<ReporteModel>) get compraSink =>
      comprasStreamController.sink.add;

  Stream<List<ReporteModel>> get compraStream => comprasStreamController.stream;

  listarCompras(dynamic idAgencia, {String fecha: ''}) async {
    consultarCompras(idAgencia, fecha: fecha);
    consultarVentas(idAgencia, fecha: fecha);
  }

  consultarCompras(dynamic idAgencia, {String fecha: ''}) async {
    final comprasResponse =
        await _reporteProvider.obtenerCompras(idAgencia, fecha);
    compraSink(comprasResponse);
  }

  final ventasStreamController =
      StreamController<List<VentasReporteModel>>.broadcast();

  Function(List<VentasReporteModel>) get ventaSink =>
      ventasStreamController.sink.add;

  Stream<List<VentasReporteModel>> get ventaStream =>
      ventasStreamController.stream;

  consultarVentas(dynamic idAgencia, {String fecha: ''}) async {
    final ventasResponse =
        await _reporteProvider.obtenerVentas(idAgencia, fecha);
    ventaSink(ventasResponse);
  }

  void disposeStreams() {
    comprasStreamController?.close();
    ventasStreamController?.close();
  }
}
