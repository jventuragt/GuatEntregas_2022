import 'dart:async';

import '../model/card_model.dart';
import '../providers/card_provider.dart';
import '../sistema.dart';

class CardBloc {
  final CardProvider _cardProvider = CardProvider();
  CardModel cardSeleccionada = CardModel();

  List<CardModel> cardes = [];

  static CardBloc _instancia;

  CardBloc._internal();

  factory CardBloc() {
    if (_instancia == null) {
      _instancia = CardBloc._internal();
    }
    return _instancia;
  }

  final cardesStreamController = StreamController<List<CardModel>>.broadcast();

  Function(List<CardModel>) get cardSink => cardesStreamController.sink.add;

  Stream<List<CardModel>> get cardStream => cardesStreamController.stream;

  final cardSeleccionaStreamController =
      StreamController<CardModel>.broadcast();

  Function(CardModel) get cardSeleccionadaSink =>
      cardSeleccionaStreamController.sink.add;

  Stream<CardModel> get cardSeleccionadaStream =>
      cardSeleccionaStreamController.stream;

  actualizar(CardModel cardModel) {
    cardSeleccionada = cardModel;
    cardSeleccionaStreamController.add(cardModel);
  }

  canejar(String codigo, Function response) async {
    await _cardProvider.canejar(codigo, response);
    final String idAgencia = '0';
    listar(idAgencia);
  }

  Future<List<CardModel>> listar(String idAgencia) async {
    final cardesResponse = await _cardProvider.listar(idAgencia);
    cardes.clear();
    //Solo el idAgencia es diferente de 0 significa que vamos a usar Curiosity Pay
    if (idAgencia == '0') {
      cardes.add(CardModel(
          modo: Sistema.EFECTIVO,
          number: Sistema.EFECTIVO,
          type: Sistema.EFECTIVO,
          holderName: 'Pagar en efectivo'));
    }
    cardes.addAll(cardesResponse);
    cardSink(cardes);
    return cardesResponse;
  }

  Future crear(CardModel cardModel) async {
    await _cardProvider.crear(cardModel);
    cardes.add(cardModel);
    cardSink(cardes);
  }

  Future eliminar(CardModel cardModel) async {
    await _cardProvider.eliminar(cardModel);
    cardes.remove(cardModel);
    cardSink(cardes);
    return;
  }

  void disposeStreams() {
    cardesStreamController?.close();
    cardSeleccionaStreamController?.close();
  }
}
