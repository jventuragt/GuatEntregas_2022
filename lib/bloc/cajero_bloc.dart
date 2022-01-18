import 'dart:async';

import '../model/cajero_model.dart';
import '../model/chat_compra_model.dart';
import '../model/despacho_model.dart';
import '../providers/cajero_provider.dart';

class CajeroBloc {
  final CajeroProvider _cajeroProvider = CajeroProvider();
  List<CajeroModel> cajeros = [];

  static CajeroBloc _instancia;

  CajeroBloc._internal();

  factory CajeroBloc() {
    if (_instancia == null) {
      _instancia = CajeroBloc._internal();
    }
    return _instancia;
  }

  void disposeStreams() {
    cajerosStreamController?.close();
  }

  final cajerosStreamController =
      StreamController<List<CajeroModel>>.broadcast();

  Function(List<CajeroModel>) get cajeroSink =>
      cajerosStreamController.sink.add;

  Stream<List<CajeroModel>> get cajeroStream => cajerosStreamController.stream;

  Future listarEnCamino({bool isConsultar: false}) async {
    if (isConsultar) {
      cajeros.clear();
      cajeroSink(cajeros);
    }

    final cajerosResponse = await _cajeroProvider.listarEnCamino();

    if (!isConsultar) {
      cajeros.clear();
    }

    cajeros.addAll(cajerosResponse);

    cajeroSink(cajeros);
    return;
  }

  Future refresh() async {
    List<CajeroModel> old = [];
    old.addAll(cajeros);
    cajeros.clear();
    cajeros.addAll(old);
    cajeroSink(cajeros);
    return;
  }

  actualizarPorChat(ChatCompraModel chatCompra) async {
    cajeros.forEach((cajeroModel) {
      if (cajeroModel.idCompra.toString() == chatCompra.idCompra.toString()) {
        cajeroModel.sinLeerCliente = 1;
        cajeroModel.idCompraEstado = chatCompra.idCompraEstado;
      }
    });
    cajeroSink(cajeros);
  }

  actualizaridDespacho(
      dynamic idCompra, dynamic idDespacho, dynamic idCompraEstado) async {
    cajeros.forEach((cajeroModel) {
      if (cajeroModel.idCompra.toString() == idCompra.toString()) {
        cajeroModel.sinLeerCliente = 1;
        cajeroModel.idCompraEstado = idCompraEstado;
        cajeroModel.idDespacho = idDespacho;
      }
    });
    cajeroSink(cajeros);
  }

  actualizarPorDespacho(DespachoModel despacho, dynamic idCompraEstado) async {
    cajeros.forEach((cajeroModel) {
      if (cajeroModel.idCompra.toString() == despacho.idCompra.toString()) {
        cajeroModel.sinLeerCliente = 0;
        cajeroModel.idCompraEstado = idCompraEstado;
      }
    });
    cajeroSink(cajeros);
  }

  actualizarPorEntrega(dynamic idDespacho, dynamic idCompraEstado) async {
    cajeros.forEach((cajeroModel) {
      if (cajeroModel.idDespacho.toString() == idDespacho.toString()) {
        cajeroModel.sinLeerCliente = 1;
        cajeroModel.calificarCliente = 1;
        cajeroModel.idCompraEstado = idCompraEstado;
      }
    });
    cajeroSink(cajeros);
  }

  actualizarPorCajero(CajeroModel cajero) async {
    cajeros.forEach((cajeroModel) {
      if (cajeroModel.idCompra.toString() == cajero.idCompra.toString()) {
        cajeroModel.sinLeerCliente = 0;
        cajeroModel.sinLeerCajero = 0;
        cajeroModel.idCompraEstado = cajero.idCompraEstado;
        cajeroModel.idDespacho = cajero.idDespacho;
        cajeroModel.detalle = cajero.detalle;
        cajeroModel.estado = cajero.estado;
        cajeroModel.lt = cajero.lt;
        cajeroModel.lg = cajero.lg;
        cajeroModel.ltB = cajero.ltB;
        cajeroModel.lgB = cajero.lgB;
        cajeroModel.calificarCliente = cajero.calificarCliente;
      }
    });
    cajeroSink(cajeros);
  }
}
