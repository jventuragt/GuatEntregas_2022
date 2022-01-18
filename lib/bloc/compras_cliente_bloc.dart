import 'dart:async';

import '../model/cajero_model.dart';
import '../model/chat_compra_model.dart';
import '../providers/compra_cliente_provider.dart';

class ComprasClienteBloc {
  final CompraClienteProvider _compraClienteProvider = CompraClienteProvider();

  static ComprasClienteBloc _instancia;

  ComprasClienteBloc._internal();

  factory ComprasClienteBloc() {
    if (_instancia == null) {
      _instancia = ComprasClienteBloc._internal();
    }
    return _instancia;
  }

  void disposeStreams() {
    comprasStreamController?.close();
  }

  List<CajeroModel> compras = <CajeroModel>[];

  final comprasStreamController =
      StreamController<List<CajeroModel>>.broadcast();

  Function(List<CajeroModel>) get comprasSink =>
      comprasStreamController.sink.add;

  Stream<List<CajeroModel>> get comprasStream => comprasStreamController.stream;

  Future listar(dynamic anio, dynamic mes) async {
    final comprasResponse =
        await _compraClienteProvider.listarCompras(anio, mes);
    compras.clear();
    compras.addAll(comprasResponse);
    comprasSink(compras);
    return;
  }

  actualizarPorChat(ChatCompraModel chatCompraModel) async {
    compras.forEach((cajeroModel) {
      if (cajeroModel.idCompra == chatCompraModel.idCompra) {
        cajeroModel.sinLeerCliente = 1;
      }
    });
    comprasSink(compras);
  }
}
