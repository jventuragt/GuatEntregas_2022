import 'dart:async';

import '../model/promocion_model.dart';
import '../preference/db_provider.dart';

class CarritoBloc {
  static CarritoBloc _instancia;

  CarritoBloc._internal();

  factory CarritoBloc() {
    if (_instancia == null) {
      _instancia = CarritoBloc._internal();
    }
    return _instancia;
  }

  List<PromocionModel> promociones = [];
  final promocionesStreamController =
      StreamController<List<PromocionModel>>.broadcast();

  Function(List<PromocionModel>) get promocionSink =>
      promocionesStreamController.sink.add;

  Stream<List<PromocionModel>> get promocionStream =>
      promocionesStreamController.stream;

  Future<List<PromocionModel>> listar(dynamic idUrbe) async {
    promociones.clear();
    final promocionesResponse = await DBProvider.db.listar(idUrbe);
    promociones.addAll(promocionesResponse);
    promocionSink(promociones);
    return promociones;
  }

  void disposeStreams() {
    promocionesStreamController?.close();
  }
}
