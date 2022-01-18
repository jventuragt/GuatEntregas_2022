import 'dart:async';

import '../model/chat_despacho_model.dart';
import '../model/despacho_model.dart';
import '../providers/chat_despacho_provider.dart';

class ChatDespachoBloc {
  final ChatDespachoProvider _chatDespachoProvider = ChatDespachoProvider();
  List<ChatDespachoModel> chats = [];

  static ChatDespachoBloc _instancia;

  ChatDespachoBloc._internal();

  factory ChatDespachoBloc() {
    if (_instancia == null) {
      _instancia = ChatDespachoBloc._internal();
    }
    return _instancia;
  }

  final chatsStreamController =
      StreamController<List<ChatDespachoModel>>.broadcast();

  Function(List<ChatDespachoModel>) get chatSink =>
      chatsStreamController.sink.add;

  Stream<List<ChatDespachoModel>> get chatStream =>
      chatsStreamController.stream;

  void disposeStreams() {
    chatsStreamController?.close();
  }

  Future<int> obtener(DespachoModel despachoModel) async {
    final chatsResponse = await _chatDespachoProvider.obtener(despachoModel);
    chats.clear();
    chats.addAll(chatsResponse);
    chatSink(chatsResponse);
    return 0;
  }

//  Future refresh(ChatDespachoModel chatDespachoModel) async {
//    bool _existe = false;
//    chats.forEach((_chatDespachoModel) {
//      if (_chatDespachoModel.idChat == chatDespachoModel.idChat) {
//        _existe = true;
//      }
//    });
//    if (!_existe) {
//      chats.add(chatDespachoModel);
//      chatSink(chats);
//    }
//    return;
//  }

  Future insert(ChatDespachoModel chatCompraModel) {
    chats.insert(0, chatCompraModel);
    chatSink(chats);
    return null;
  }
}
