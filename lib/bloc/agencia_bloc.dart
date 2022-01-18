import 'dart:async';

import '../model/agencia_model.dart';
import '../providers/agencia_provider.dart';

class AgenciaBloc {
  final AgenciaProvider _agenciaProvider = AgenciaProvider();
  AgenciaModel agenciaSeleccionada = AgenciaModel();

  List<AgenciaModel> agenciaes = [];

  static AgenciaBloc _instancia;

  AgenciaBloc._internal();

  factory AgenciaBloc() {
    if (_instancia == null) {
      _instancia = AgenciaBloc._internal();
    }
    return _instancia;
  }

  final agenciaesStreamController =
      StreamController<List<AgenciaModel>>.broadcast();

  Function(List<AgenciaModel>) get agenciaSink =>
      agenciaesStreamController.sink.add;

  Stream<List<AgenciaModel>> get agenciaStream =>
      agenciaesStreamController.stream;

  Future<List<AgenciaModel>> listar() async {
    final agenciaesResponse = await _agenciaProvider.listarAgencias();
    agenciaes.clear();
    agenciaes.addAll(agenciaesResponse);
    agenciaSink(agenciaes);
    return agenciaesResponse;
  }

  Future<List<AgenciaModel>> listaPreregistros(selectedIndex) async {
    final agenciaesResponse =
        await _agenciaProvider.listarPreRegistros(selectedIndex);
    agenciaes.clear();
    agenciaes.addAll(agenciaesResponse);
    agenciaSink(agenciaes);
    return agenciaesResponse;
  }

  Future<List<AgenciaModel>> filtrar(String pattern) async {
    final agenciaesResponse =
        await _agenciaProvider.listarAgencias(bCriterio: pattern);
    agenciaes.clear();
    agenciaes.addAll(agenciaesResponse);
    agenciaSink(agenciaes);
    return agenciaesResponse;
  }

  void disposeStreams() {
    agenciaesStreamController?.close();
  }
}
