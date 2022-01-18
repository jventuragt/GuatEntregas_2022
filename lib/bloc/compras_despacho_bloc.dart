import 'dart:async';

import '../model/chat_despacho_model.dart';
import '../model/despacho_model.dart';
import '../providers/despacho_provider.dart';
import '../utils/conf.dart' as conf;

class ComprasDespachoBloc {
  final DespachoProvider _despachoProvider = DespachoProvider();

  static ComprasDespachoBloc _instancia;

  ComprasDespachoBloc._internal();

  factory ComprasDespachoBloc() {
    if (_instancia == null) {
      _instancia = ComprasDespachoBloc._internal();
    }
    return _instancia;
  }

  void disposeStreams() {
    comprasStreamController?.close();
  }

  List<DespachoModel> compras = [];

  final comprasStreamController =
      StreamController<List<DespachoModel>>.broadcast();

  Function(List<DespachoModel>) get comprasSink =>
      comprasStreamController.sink.add;

  Stream<List<DespachoModel>> get comprasStream =>
      comprasStreamController.stream;

  //tipo 0 son compras que se esta despachando si es 1 son de historial y se requiere la fecha
  Future listarCompras(int tipo, String fecha) async {
    final comprasResponse = await _despachoProvider.listarCompras(tipo, fecha);
    compras.clear();
    compras.addAll(comprasResponse);
    comprasSink(compras);
    return;
  }

  //tipo 0 son compras que se esta despachando si es 1 son de historial y se requiere la fecha
  actualizarCompras(
      ChatDespachoModel chatDespachoModel, int tipo, String fecha) async {
    bool nuevaCompra = true;
    compras.forEach((despachoModel) {
      if (despachoModel.idDespacho == chatDespachoModel.idDespacho) {
        despachoModel.sinLeerCliente = 1;
        despachoModel.idDespachoEstado = chatDespachoModel.idDespachoEstado;
        nuevaCompra = false;
        if (chatDespachoModel.tipo == conf.CHAT_TIPO_CONFIRMACION) {
          despachoModel.costo = chatDespachoModel.valor;
        }
      }
    });
    if (nuevaCompra) return listarCompras(tipo, fecha);
    comprasSink(compras);
  }

  actualizarPorDespacho(DespachoModel despacho) async {
    compras.forEach((despachoModel) {
      if (despachoModel.idCompra == despacho.idCompra) {
        despachoModel.sinLeerConductor = 0;
        despachoModel.idDespachoEstado = despacho.idDespachoEstado;
        despachoModel.estado = despacho.estado;
        despachoModel.preparandose = despacho.preparandose;
      }
    });
    comprasSink(compras);
  }

  Future nuevo(DespachoModel despacho) async {
    for (var element in compras)
      if (element.idDespacho.toString() == despacho.idDespacho.toString())
        return;
    compras.add(despacho);
    comprasSink(compras);
    return;
  }

  Future eliminar(DespachoModel despacho) async {
    compras.remove(despacho);
    comprasSink(compras);
    return;
  }
}
