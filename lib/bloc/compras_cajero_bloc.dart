import 'dart:async';

import '../model/cajero_model.dart';
import '../model/chat_compra_model.dart';
import '../providers/cajero_provider.dart';
import '../utils/conf.dart' as conf;

class ComprasCajeroBloc {
  final CajeroProvider _cajeroProvider = CajeroProvider();

  static ComprasCajeroBloc _instancia;

  ComprasCajeroBloc._internal();

  factory ComprasCajeroBloc() {
    if (_instancia == null) {
      _instancia = ComprasCajeroBloc._internal();
    }
    return _instancia;
  }

  void disposeStreams() {
    comprasStreamController?.close();
  }

  List<CajeroModel> compras = [];

  final comprasStreamController =
      StreamController<List<CajeroModel>>.broadcast();

  Function(List<CajeroModel>) get comprasSink =>
      comprasStreamController.sink.add;

  Stream<List<CajeroModel>> get comprasStream => comprasStreamController.stream;

  //tipo 0 son compras que se esta despachando si es 1 son de historial y se requiere la fecha
  Future listarCompras(int tipo, String fecha) async {
    final comprasResponse = await _cajeroProvider.listarCompras(tipo, fecha);
    compras.clear();
    compras.addAll(comprasResponse);
    comprasSink(compras);
    return;
  }

  //tipo 0 son compras que se esta despachando si es 1 son de historial y se requiere la fecha
  actualizarCompras(
      ChatCompraModel chatCompraModel, int tipo, String fecha) async {
    bool nuevaCompra = true;
    compras.forEach((cajeroModel) {
      if (cajeroModel.idCompra == chatCompraModel.idCompra) {
        cajeroModel.sinLeerCajero = 1;
        cajeroModel.idCompraEstado = chatCompraModel.idCompraEstado;
        nuevaCompra = false;
        if (chatCompraModel.tipo == conf.CHAT_TIPO_CONFIRMACION) {
          cajeroModel.costo = chatCompraModel.valor;
          cajeroModel.detalle = chatCompraModel.mensaje;
        }
      }
    });
    if (nuevaCompra) return listarCompras(tipo, fecha);
    comprasSink(compras);
  }

  actualizarPorCajero(CajeroModel cajero) async {
    compras.forEach((CajeroModel cajeroModel) {
      if (cajeroModel.idCompra == cajero.idCompra) {
        cajeroModel.sinLeerCajero = 0;
        cajeroModel.sinLeerCliente = 0;
        cajeroModel.idCompraEstado = cajero.idCompraEstado;
        cajeroModel.idDespacho = cajero.idDespacho;
        cajeroModel.detalle = cajero.detalle;
        cajeroModel.estado = cajero.estado;
        cajeroModel.lt = cajero.lt;
        cajeroModel.lg = cajero.lg;
        cajeroModel.ltB = cajero.ltB;
        cajeroModel.lgB = cajero.lgB;
      }
    });
    comprasSink(compras);
  }
}
