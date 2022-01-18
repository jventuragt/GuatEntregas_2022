import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../preference/shared_preferences.dart';
import '../sistema.dart';
import '../utils/utils.dart' as utils;

class Conexion {
  static Conexion _instancia;

  Conexion._internal();

  factory Conexion() {
    if (_instancia == null) {
      _instancia = Conexion._internal();
    }
    _instancia.conectar();
    return _instancia;
  }

  final _prefs = PreferenciasUsuario();

  IO.Socket socket;

  final conexionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Function(Map<String, dynamic>) get sink => conexionStreamController.sink.add;

  Stream<Map<String, dynamic>> get stream => conexionStreamController.stream;

  conectar() {
    if (socket != null && socket.connected) return;
    socket = IO.io(Sistema.dominio, <String, dynamic>{
      'transports': ['websocket'],
      'query': {'idcliente': _prefs.idCliente, 'imei': utils.imei}
    });
    socket.connect();
    socket.on('l', (data) {
      if (data['t'] == 1) sink(data['l']);
    });
  }

  desconectar() {
    if (socket == null) return;
    socket.clearListeners();
    socket.close();
    socket = null;
  }

  isConnect() {
    return socket?.connected;
  }

  void disposeStreams() {
    conexionStreamController?.close();
  }
}
