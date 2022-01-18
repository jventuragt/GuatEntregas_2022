import 'dart:async';

import '../model/compra_promocion_model.dart';
import '../providers/compra_provider.dart';

class ComprasBloc {
  final CompraProvider _compraProvider = CompraProvider();

  static ComprasBloc _instancia;

  ComprasBloc._internal();

  factory ComprasBloc() {
    if (_instancia == null) {
      _instancia = ComprasBloc._internal();
    }
    return _instancia;
  }

  final compraPromocionesStreamController =
      StreamController<List<CompraPromocionModel>>.broadcast();

  Function(List<CompraPromocionModel>) get compraPromocionSink =>
      compraPromocionesStreamController.sink.add;

  Stream<List<CompraPromocionModel>> get compraPromocionStream =>
      compraPromocionesStreamController.stream;

  List<CompraPromocionModel> comprasPromociones = [];

  Future listarCompraPromociones(dynamic idCompra) async {
    comprasPromociones.clear();
    compraPromocionSink(comprasPromociones);
    final compraPromocionesResponse =
        await _compraProvider.listarCompraPromociones(idCompra);
    comprasPromociones.addAll(compraPromocionesResponse);
    compraPromocionSink(comprasPromociones);
    return;
  }

  void disposeStreams() {
    compraPromocionesStreamController?.close();
  }
}
