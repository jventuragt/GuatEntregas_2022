import 'dart:async';

import '../model/notificacion_model.dart';
import '../providers/notificacion_provider.dart';

class NotificacionBloc {
  final NotificacionProvider _notificacionProvider = NotificacionProvider();
  NotificacionModel notificacionSeleccionada = NotificacionModel();

  List<NotificacionModel> notificaciones = [];

  static NotificacionBloc _instancia;

  NotificacionBloc._internal();

  factory NotificacionBloc() {
    if (_instancia == null) {
      _instancia = NotificacionBloc._internal();
    }
    return _instancia;
  }

  final notificacionesStreamController =
      StreamController<List<NotificacionModel>>.broadcast();

  Function(List<NotificacionModel>) get notificacionSink =>
      notificacionesStreamController.sink.add;

  Stream<List<NotificacionModel>> get notificacionStream =>
      notificacionesStreamController.stream;

  Future<List<NotificacionModel>> listar() async {
    final notificacionesResponse =
        await _notificacionProvider.listarNotificaciones();
    notificaciones.clear();
    notificaciones.addAll(notificacionesResponse);
    notificacionSink(notificaciones);
    return notificacionesResponse;
  }

  void disposeStreams() {
    notificacionesStreamController?.close();
  }
}
