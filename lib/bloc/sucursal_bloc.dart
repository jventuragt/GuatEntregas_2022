import 'dart:async';

import '../model/sucursal_model.dart';
import '../providers/sucursal_provider.dart';

class SucursalBloc {
  final SucursalProvider _sucursalProvider = SucursalProvider();
  SucursalModel sucursalSeleccionada = SucursalModel();

  List<SucursalModel> sucursales = [];

  static SucursalBloc _instancia;

  SucursalBloc._internal();

  factory SucursalBloc() {
    if (_instancia == null) {
      _instancia = SucursalBloc._internal();
    }
    return _instancia;
  }

  final sucursalesStreamController =
      StreamController<List<SucursalModel>>.broadcast();

  Function(List<SucursalModel>) get sucursalSink =>
      sucursalesStreamController.sink.add;

  Stream<List<SucursalModel>> get sucursalStream =>
      sucursalesStreamController.stream;

  Future listar(dynamic idAgencia) async {
    List<SucursalModel> sucursalesResponse =
        await _sucursalProvider.listarSucursales(idAgencia);
    sucursales.clear();
    sucursales.addAll(sucursalesResponse);
    sucursalSink(sucursales);
    return;
  }

  Future<List<SucursalModel>> filtrar(String pattern) async {
    sucursales.sort((a, b) =>
        (a.sucursal.toString().toUpperCase().contains(pattern.toUpperCase())
            ? 0
            : 1));
    return sucursales;
  }

  Future<List<SucursalModel>> buscar(String pattern) async {
    List<SucursalModel> sucursalesResponse =
        await _sucursalProvider.buscarSucursales(pattern);
    sucursales.clear();
    sucursales.addAll(sucursalesResponse);
    sucursalSink(sucursales);
    return sucursales;
  }

//  Future crear(SucursalModel sucursalModel) async {
//    final idSucursal = await _sucursalProvider.crearSucursal(sucursalModel);
//    sucursalModel.idSucursal = idSucursal;
//    sucursales.add(sucursalModel);
//    sucursalSink(sucursales);
//  }

  Future editar(SucursalModel sucursalModel) async {
    await _sucursalProvider.editarSucursal(sucursalModel);
    sucursalSink(sucursales);
  }

  void disposeStreams() {
    sucursalesStreamController?.close();
  }
}
