import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class IntentShare {
  static IntentShare _instancia;

  StreamSubscription _intentDataStreamSubscription;
  String _intentShare = '';

  final intentStreamController = StreamController<String>.broadcast();

  Function(String) get intentSink => intentStreamController.sink.add;

  Stream<String> get intentStream => intentStreamController.stream;

  IntentShare._internal();

  factory IntentShare() {
    if (_instancia == null) {
      _instancia = IntentShare._internal();
    }
    return _instancia;
  }

  void initIntentShare() async {
    try {
      _intentDataStreamSubscription =
          ReceiveSharingIntent.getTextStream().listen((String value) {
        intentSink('');
        _intentShare = value;
        intentSink(_intentShare);
      }, onError: (err) {
        print("getLinkStream error: $err");
      });
      ReceiveSharingIntent.getInitialText().then((String value) {
        intentSink('');
        _intentShare = value;
        intentSink(_intentShare);
      });
    } catch (err) {
      print("initIntentShare error: $err");
    }
  }

  String get intentShare => _intentShare;

  set intentShare(value) => _intentShare = value;

  void disposeStreams() {
    intentStreamController?.close();
    _intentDataStreamSubscription?.cancel();
  }
}
