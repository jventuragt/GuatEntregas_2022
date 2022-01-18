import 'dart:async';

import '../model/chat_compra_model.dart';
import '../providers/chat_compra_provider.dart';

class ChatCompraBloc {
  final ChatCompraProvider _chatCompraProvider = ChatCompraProvider();
  List<ChatCompraModel> chats = [];

  static ChatCompraBloc _instancia;

  ChatCompraBloc._internal();

  factory ChatCompraBloc() {
    if (_instancia == null) {
      _instancia = ChatCompraBloc._internal();
    }
    return _instancia;
  }

  final chatsStreamController =
      StreamController<List<ChatCompraModel>>.broadcast();

  Function(List<ChatCompraModel>) get chatSink =>
      chatsStreamController.sink.add;

  Stream<List<ChatCompraModel>> get chatStream => chatsStreamController.stream;

  void disposeStreams() {
    chatsStreamController?.close();
  }

  Future<int> obtener(dynamic idCompra) async {
    final chatsResponse = await _chatCompraProvider.obtener(idCompra);
    chats.clear();
    chats.addAll(chatsResponse);
    chatSink(chatsResponse);
    return 0;
  }

//  Future refresh(ChatCompraModel chatCompraModel) async {
//    bool _existe = false;
//    chats.forEach((cajeroModel) {
//      if (cajeroModel.idChat == chatCompraModel.idChat) {
//        _existe = true;
//      }
//    });
//    if (!_existe) {
//      chats.insert(0, chatCompraModel);
////      chats.add(chatCompraModel);
//      chatSink(chats);
//    }
//    return;
//  }

  insert(ChatCompraModel chatCompraModel) {
    chats.insert(0, chatCompraModel);
    chatSink(chats);
  }
}
