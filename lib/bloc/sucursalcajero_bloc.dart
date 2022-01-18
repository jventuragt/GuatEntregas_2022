import 'dart:async';

import '../model/sucursalcajero_model.dart';
import '../providers/sucursalcajero_provider.dart';

class SucursalcajeroBloc {
  final SucursalcajeroProvider _sucursalcajeroProvider =
      SucursalcajeroProvider();
  SucursalcajeroModel sucursalcajeroSeleccionada = SucursalcajeroModel();

  List<SucursalcajeroModel> sucursalcajeros = [];

  static SucursalcajeroBloc _instancia;

  SucursalcajeroBloc._internal();

  factory SucursalcajeroBloc() {
    if (_instancia == null) {
      _instancia = SucursalcajeroBloc._internal();
    }
    return _instancia;
  }

  final sucursalcajeroesStreamController =
      StreamController<List<SucursalcajeroModel>>.broadcast();

  Function(List<SucursalcajeroModel>) get sucursalcajeroSink =>
      sucursalcajeroesStreamController.sink.add;

  Stream<List<SucursalcajeroModel>> get sucursalcajeroStream =>
      sucursalcajeroesStreamController.stream;

  Future<List<SucursalcajeroModel>> listar(dynamic idSucursal) async {
    final sucursalcajeroesResponse =
        await _sucursalcajeroProvider.listarSucursalcajeros(idSucursal);
    sucursalcajeros.clear();
    sucursalcajeros.addAll(sucursalcajeroesResponse);
//    sucursalcajeros.add(new SucursalcajeroModel(
//        idSucursalSucursalcajero: -1,
//        desde: 'Registrar sucursalcajero',
//        hasta: 'Toca para registrar un sucursalcajero',
////        img: 'assets/screen/direcciones.png'
//    ));
    sucursalcajeroSink(sucursalcajeros);
    return sucursalcajeroesResponse;
  }

  Future editar(SucursalcajeroModel sucursalcajeroModel) async {
    sucursalcajeroModel =
        await _sucursalcajeroProvider.editarSucursalcajero(sucursalcajeroModel);
    sucursalcajeroSink(sucursalcajeros);
    return;
  }

  void disposeStreams() {
    sucursalcajeroesStreamController?.close();
  }
}
