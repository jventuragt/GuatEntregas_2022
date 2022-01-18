import 'dart:async';

import '../model/factura_model.dart';
import '../providers/factura_provider.dart';

class FacturaBloc {
  final FacturaProvider _facturaProvider = FacturaProvider();
  FacturaModel facturaSeleccionada = FacturaModel();

  List<FacturaModel> facturas = [];

  static FacturaBloc _instancia;

  FacturaBloc._internal();

  factory FacturaBloc() {
    if (_instancia == null) {
      _instancia = FacturaBloc._internal();
    }
    return _instancia;
  }

  final facturaesStreamController =
      StreamController<List<FacturaModel>>.broadcast();

  Function(List<FacturaModel>) get facturaSink =>
      facturaesStreamController.sink.add;

  Stream<List<FacturaModel>> get facturaStream =>
      facturaesStreamController.stream;

  Future<List<FacturaModel>> listar() async {
    final facturaesResponse = await _facturaProvider.listarFacturaes();
    facturas.clear();
    facturas.addAll(facturaesResponse);
    facturas.add(new FacturaModel(
      idFactura: -1,
      dni: '',
      direccion: '',
    ));
    facturaSink(facturas);
    return facturaesResponse;
  }

  obtener() async {
    if (facturas.length > 0) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        facturaSink(facturas);
      });
      return;
    }
    listar();
  }

  Future<FacturaModel> crear(FacturaModel facturaModel) async {
    FacturaModel facturaModelResponse =
        await _facturaProvider.crearFactura(facturaModel);
    facturas.add(new FacturaModel(
      idFactura: -1,
      dni: '',
      direccion: '',
    ));
    facturaSink(facturas);
    return facturaModelResponse;
  }

  Future<bool> editar(FacturaModel facturaModel) async {
    bool editado = await _facturaProvider.editarFactura(facturaModel);
    facturaSink(facturas);
    return editado;
  }

  Future eliminar(FacturaModel facturaModel) async {
    await _facturaProvider.eliminarFactura(facturaModel);
    facturas.remove(facturaModel);
    facturaSink(facturas);
    return;
  }

  void disposeStreams() {
    facturaesStreamController?.close();
  }
}
