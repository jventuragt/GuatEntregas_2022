import 'dart:async';
import 'dart:io';

class FotoBloc {
  static FotoBloc _instancia;

  FotoBloc._internal();

  factory FotoBloc() {
    if (_instancia == null) {
      _instancia = FotoBloc._internal();
    }
    return _instancia;
  }

  File imageFile;
  final fotoStreamController = StreamController<bool>.broadcast();

  Function(bool) get fotoSink => fotoStreamController.sink.add;

  Stream<bool> get fotoStream => fotoStreamController.stream;

  void disposeStreams() {
    fotoStreamController?.close();
  }
}
