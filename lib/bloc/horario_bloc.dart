import 'dart:async';

import '../model/horario_model.dart';
import '../providers/horario_provider.dart';

class HorarioBloc {
  final HorarioProvider _horarioProvider = HorarioProvider();
  HorarioModel horarioSeleccionada = HorarioModel();

  List<HorarioModel> horarios = [];

  static HorarioBloc _instancia;

  HorarioBloc._internal();

  factory HorarioBloc() {
    if (_instancia == null) {
      _instancia = HorarioBloc._internal();
    }
    return _instancia;
  }

  final horarioesStreamController =
      StreamController<List<HorarioModel>>.broadcast();

  Function(List<HorarioModel>) get horarioSink =>
      horarioesStreamController.sink.add;

  Stream<List<HorarioModel>> get horarioStream =>
      horarioesStreamController.stream;

  Future<List<HorarioModel>> listar(dynamic idSucursal) async {
    final horarioesResponse = await _horarioProvider.listarHorarios(idSucursal);
    horarios.clear();
    horarios.addAll(horarioesResponse);
//    horarios.add(new HorarioModel(
//        idSucursalHorario: -1,
//        desde: 'Registrar horario',
//        hasta: 'Toca para registrar un horario',
////        img: 'assets/screen/direcciones.png'
//    ));
    horarioSink(horarios);
    return horarioesResponse;
  }

  Future editar(HorarioModel horarioModel) async {
    await _horarioProvider.editarHorario(horarioModel);
    horarioSink(horarios);
    return;
  }

  void disposeStreams() {
    horarioesStreamController?.close();
  }
}
