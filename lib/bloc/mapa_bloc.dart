import 'dart:async';

import '../providers/mapa_provider.dart';

class MapaBloc {
  final MapaProvider _mapaProvider = MapaProvider();

  List mapaes = [];

  static MapaBloc _instancia;

  MapaBloc._internal();

  factory MapaBloc() {
    if (_instancia == null) {
      _instancia = MapaBloc._internal();
    }
    return _instancia;
  }

  final mapaesStreamController = StreamController<List>.broadcast();

  Function(List) get mapaSink => mapaesStreamController.sink.add;

  Stream<List> get mapaStream => mapaesStreamController.stream;

  Future<List> filtrar(double lt, double lg, dynamic criterio) async {
    final mapaesResponse =
        await _mapaProvider.lugaresCercanos(lt, lg, criterio);
    mapaes.clear();
    mapaes.addAll(mapaesResponse);
    mapaSink(mapaes);
    return mapaesResponse;
  }

  void disposeStreams() {
    mapaesStreamController?.close();
  }
}
